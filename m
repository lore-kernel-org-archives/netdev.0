From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH iproute2 2/2] ip rule: add selector support
Date: Fri, 23 Sep 2016 11:06:24 +0800
Message-ID: <CAPwn2JS9Fo41QeA8eBvz-tY_c7CFvtCyWsHTXwrfxhRa5vN_3Q@mail.gmail.com>
References: <1474525729-2845-1-git-send-email-liuhangbin@gmail.com>
 <1474525729-2845-3-git-send-email-liuhangbin@gmail.com> <20160922084553.GA22100@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Phil Sutter <phil@nwl.cc>, Hangbin Liu <liuhangbin@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:33690 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752365AbcIWDGZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 23:06:25 -0400
Received: by mail-oi0-f45.google.com with SMTP id r126so120458396oib.0
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 20:06:25 -0700 (PDT)
In-Reply-To: <20160922084553.GA22100@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-09-22 16:45 GMT+08:00 Phil Sutter <phil@nwl.cc>:
> On Thu, Sep 22, 2016 at 02:28:49PM +0800, Hangbin Liu wrote:
> [...]
>> diff --git a/man/man8/ip-rule.8 b/man/man8/ip-rule.8
>> index 3508d80..ec0e31d 100644
>> --- a/man/man8/ip-rule.8
>> +++ b/man/man8/ip-rule.8
>> @@ -15,7 +15,8 @@ ip-rule \- routing policy database management
>>
>>  .ti -8
>>  .B  ip rule
>> -.RB "[ " list " ]"
>> +.RB "[ " list
>> +.I "[ " SELECTOR " ]]"
>
> This makes the brackets cursive, too. Better use this instead:
>
> | .RI "[ " SELECTOR " ]]"

Thanks Phil, I'm not familiar with man doc syntax :)

Cheers
Hangbin
