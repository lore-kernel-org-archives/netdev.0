From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 04/10] net: sched: replace nprio by a bool to
 make the function more readable
Date: Tue, 16 May 2017 14:25:32 +0200
Message-ID: <20170516122532.GL1939@nanopsycho.orion>
References: <20170515083857.3615-1-jiri@resnulli.us>
 <20170515083857.3615-5-jiri@resnulli.us>
 <0553194d-9d76-bb39-4b29-c3c734a6ff44@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, stephen@networkplumber.org,
        daniel@iogearbox.net, alexander.h.duyck@intel.com,
        simon.horman@netronome.com, mlxsw@mellanox.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34464 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752519AbdEPMZk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 08:25:40 -0400
Received: by mail-wm0-f66.google.com with SMTP id d127so37767874wmf.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 05:25:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <0553194d-9d76-bb39-4b29-c3c734a6ff44@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 16, 2017 at 02:09:25PM CEST, jhs@mojatatu.com wrote:
>On 17-05-15 04:38 AM, Jiri Pirko wrote:
>
>> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
>> index 88ec1a1..0e49e6e 100644
>> --- a/net/sched/cls_api.c
>> +++ b/net/sched/cls_api.c
>> @@ -271,7 +271,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
>>  	struct tcmsg *t;
>>  	u32 protocol;
>>  	u32 prio;
>> -	u32 nprio;
>> +	bool prio_allocate;
>
>prio_allocated? (past tense seems more sensible)

No, it actually tell if the prio should be allocated:

                if (prio_allocate)
                        prio = tcf_auto_prio(tcf_chain_tp_prev(&chain_info));

I believe it is accurate.
