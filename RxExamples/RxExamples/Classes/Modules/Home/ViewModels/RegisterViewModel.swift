//
//  RegisterViewModel.swift
//  RxExamples
//
//  Created by jin on 2019/5/28.
//  Copyright © 2019 晋先森. All rights reserved.
//

import Foundation
import Validator
import ObjectMapper
import Moya_ObjectMapper

struct ValidatorError: ValidationError {
    
    public let message: String
    
    public init(message m: String) {
        message = m
    }
}
 

class RegisterViewModel: BaseViewModel {
    
}

extension RegisterViewModel: ViewModelType {
    
    struct Input {
        let account: Driver<String>
        let password: Driver<String>
    }
    
    struct Output {
        let registerEnable: Driver<Bool>
    }
    
    func transform(input: RegisterViewModel.Input) -> RegisterViewModel.Output {
       
        // 账号验证
        let accountValidated = input.account.map { value -> Bool in
            let valid = ValidationRuleLength(min: 8, max: 18,
                                             lengthType: .utf8,
                                             error: ValidatorError(message: "无效账号"))
            return value.validate(rule: valid).isValid
        }
        
        // 密码验证
        let passwordValidated = input.password.map { value -> Bool in
            let valid = ValidationRuleLength(min: 6, max: 18, error: ValidatorError(message: "密码无效"))
            return value.validate(rule: valid).isValid
        }
        let registerEnable = Driver.combineLatest(accountValidated, passwordValidated) {
            $0 && $1
            }.distinctUntilChanged() // 丢弃重复值
        
        return Output(registerEnable: registerEnable)
        
    }
}


extension RegisterViewModel {
    
    func registerUser(account: String,
                      password: String) -> Observable<Token> {
        return UserProvider.requestData(.register(account: account,
                                                  password: password))
            .mapObject(Token.self)
            .trackError(error)
            .trackActivity(loading)
    }
}
