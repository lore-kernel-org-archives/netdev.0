From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v6 3/3] net sched actions: add time filter for
 action dumping
Date: Fri, 21 Apr 2017 11:13:37 -0400
Message-ID: <3463713e-235a-32f4-0956-d621b7305d7e@mojatatu.com>
References: <1492772132-16559-1-git-send-email-jhs@emojatatu.com>
 <1492772132-16559-4-git-send-email-jhs@emojatatu.com>
 <20170421131347.GD1874@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33286 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424844AbdDUTYL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:24:11 -0400
Received: by mail-io0-f194.google.com with SMTP id k87so33499042ioi.0
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 12:24:06 -0700 (PDT)
In-Reply-To: <20170421131347.GD1874@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-21 09:13 AM, Jiri Pirko wrote:
> Fri, Apr 21, 2017 at 12:55:32PM CEST, jhs@mojatatu.com wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>

>> @@ -1000,6 +1008,7 @@ static int tcf_action_add(struct net *net, struct nlattr *nla,
>>
>> static const struct nla_policy tcaa_policy[TCA_ROOT_MAX + 1] = {
>> 	[TCA_ROOT_FLAGS]      = { .type = NLA_U32 },
>> +	[TCA_ROOT_TIME_DELTA]      = { .type = NLA_U32 },
>
> Align these assignments please.
>

Will do next update.

cheers,
jamal
