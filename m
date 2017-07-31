From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v12 1/4] net netlink: Add new type NLA_BITFIELD32
Date: Mon, 31 Jul 2017 08:03:55 -0400
Message-ID: <fa171203-adab-9950-8241-dd5b3a70fe0a@mojatatu.com>
References: <1501435492-28301-1-git-send-email-jhs@emojatatu.com>
 <1501435492-28301-2-git-send-email-jhs@emojatatu.com>
 <20170730184242.GA1872@nanopsycho>
 <98edc93f-b5d9-e73f-ff00-9403e8362f80@mojatatu.com>
 <20170731063833.GB1883@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        horms@verge.net.au, dsahern@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36955 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751950AbdGaMD6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 08:03:58 -0400
Received: by mail-io0-f193.google.com with SMTP id c74so10530192iod.4
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 05:03:58 -0700 (PDT)
In-Reply-To: <20170731063833.GB1883@nanopsycho>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-07-31 02:38 AM, Jiri Pirko wrote:
> Sun, Jul 30, 2017 at 09:59:10PM CEST, jhs@mojatatu.com wrote:
>> Jiri,
>>
>> This is getting exhausting, seriously.
>> I posted the code you are commenting one two days ago so i dont have to
>> repost.
> 
> And I commented on the "*u32 = *u32" thing. But you ignored it. Pardon
> me for mentioning that again now :/
> 

You commented on *u32 assignment from *void which i fixed. I
intentionally selected the different assignment names to reflect
meaning. Had you commented earlier - although I would have found
it disagreable - I would have fixed that too. Jiri, you need to be
more tolerant so progress can be made at times.

> 
>>
>> On D. Ahern: I dont think we are disagreeing anymore on the need to
>> generalize the check. He is saying it should be a helper and I already
>> had the validation data; either works. I dont see the gapping need
>> to remove the validation data.
> 
> DavidA? Your opinion.
> 

With DavidA(reading his response) - the issue is one of taste.
Again either approach is fine. You can call helpers for every user
or make them invoked behind the scenes.
Again - like all your comments on code taste which I addressed, I
would have made that change if the comment had come in earlier. I got
exhausted. Imagine how a newbie corporate guy wouldve felt after this.

cheers,
jamal
