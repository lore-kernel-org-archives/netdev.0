From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next] net: sched: add helpers to handle extended
 actions
Date: Tue, 2 May 2017 07:57:52 -0400
Message-ID: <39bdfccb-0d2f-bbbb-6faf-8ba1db303e10@mojatatu.com>
References: <1493396006-11084-1-git-send-email-jiri@resnulli.us>
 <6450af04-a6d4-866e-82ee-424ff54b2ef3@mojatatu.com>
 <20170502055134.GB1877@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36106 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750892AbdEBL5z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 07:57:55 -0400
Received: by mail-io0-f194.google.com with SMTP id x86so29355686ioe.3
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 04:57:55 -0700 (PDT)
In-Reply-To: <20170502055134.GB1877@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-02 01:51 AM, Jiri Pirko wrote:
> Sun, Apr 30, 2017 at 04:08:15PM CEST, jhs@mojatatu.com wrote:
>> Jiri,
>>
>> With "goto chain X" this will have to be more generalized. Maybe
>> we have 0xAXXXXXXX Where "A" recognizes the extension with
>> current values ACT_JUMP(0x1) and GOTO_CHAIN(maybe 0x2)
>> and the rest "XXXXXXX" is a free floating parameter values
>> which carry the goto count for ACT_JUMP and GOTO_CHAIN chain-id.
>
> That is exactly what this patch is doing.
>

You are right, sorry ;->

cheers,
jamal
