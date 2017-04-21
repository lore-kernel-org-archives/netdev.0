From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 21 Apr 2017 12:01:07 -0400
Message-ID: <758ff636-365f-6180-9353-69da5d339a3a@mojatatu.com>
References: <ed5c82c7-0e59-d377-fefc-3b97764d2843@mojatatu.com>
 <20170421.105156.736001860584596934.davem@davemloft.net>
 <82a6c32b-d58e-aeed-bfb5-546f328eaf35@mojatatu.com>
 <20170421.113800.1367091481085913667.davem@davemloft.net>
 <c2d61246-b92d-efef-cd07-005f8a8dacc0@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35405 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423186AbdDUSCU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:02:20 -0400
Received: by mail-io0-f196.google.com with SMTP id d203so33045385iof.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:02:20 -0700 (PDT)
In-Reply-To: <c2d61246-b92d-efef-cd07-005f8a8dacc0@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-21 11:55 AM, Jamal Hadi Salim wrote:
> On 17-04-21 11:38 AM, David Miller wrote:

>> If a user says "enable X" and it just gets simply ignored by older
>> kernels, that can't work properly.  What if "enable X" is something
>> like "turn on encryption"?  Are you OK with the user getting no
>> feedback that their stuff is not going to be encrypted?
>>
>
> For this specific use case:
> Dont they need a newer kernel which supports "enable encryption"?

Also: What happens to this user space app when it encounters an
older kernel?

Using rejection as a capability discovery wont work I think.

cheers,
jamal
