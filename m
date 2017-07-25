From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v11 4/4] net sched actions: add time filter for
 action dumping
Date: Tue, 25 Jul 2017 07:27:03 -0400
Message-ID: <bdd4e9f8-7d64-813b-fd6c-147d0bc3c0af@mojatatu.com>
References: <1500860146-26970-1-git-send-email-jhs@emojatatu.com>
 <1500860146-26970-5-git-send-email-jhs@emojatatu.com>
 <20170724113450.GD1868@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, dsahern@gmail.com,
        eric.dumazet@gmail.com, mrv@mojatatu.com,
        simon.horman@netronome.com, alex.aring@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:37403 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750860AbdGYL1F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 07:27:05 -0400
Received: by mail-io0-f196.google.com with SMTP id c74so649502iod.4
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 04:27:05 -0700 (PDT)
In-Reply-To: <20170724113450.GD1868@nanopsycho>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-07-24 07:34 AM, Jiri Pirko wrote:
> Mon, Jul 24, 2017 at 03:35:46AM CEST, jhs@mojatatu.com wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>

> 
>> @@ -128,6 +129,11 @@ static int tcf_dump_walker(struct tcf_hashinfo *hinfo, struct sk_buff *skb,
>> 			if (index < s_i)
>> 				continue;
>>
>> +			if (jiffy_since &&
>> +			    time_after(jiffy_since,
>> +				       (unsigned long)p->tcfa_tm.lastuse))
> 
> You don't need to check jiffy_since==0. Also, nicer  ^^ this with a space :)
> 

Assuming that time_after() would work fine for jiffy_since being zero,
but:
wouldnt it be more efficient to just not call time_after() altogether?

> Other than this, looks fine.

Ok, please no more changes - I am exhausted ;-> So speak for this
update or send patches afterwards if you dont like something.

cheers,
jamal
