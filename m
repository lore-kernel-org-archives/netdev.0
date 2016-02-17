From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 5/8] net: tc: helper functions to query action
 types
Date: Tue, 16 Feb 2016 19:21:59 -0800
Message-ID: <56C3E757.7070704@gmail.com>
References: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810> <20160216060216.32452.72576.stgit@john-Precision-Tower-5810> <20160216202658.GE2246@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: amir@vadai.me, jhs@mojatatu.com, davem@davemloft.net,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35313 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756263AbcBQDWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 22:22:14 -0500
Received: by mail-pf0-f182.google.com with SMTP id c10so3229138pfc.2
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 19:22:14 -0800 (PST)
In-Reply-To: <20160216202658.GE2246@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-16 12:26 PM, Jiri Pirko wrote:
> Tue, Feb 16, 2016 at 07:02:16AM CET, john.fastabend@gmail.com wrote:
>> This is a helper function drivers can use to learn if the
>> action type is a drop action.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>> include/net/tc_act/tc_gact.h |   16 ++++++++++++++++
>> 1 file changed, 16 insertions(+)
>>
>> diff --git a/include/net/tc_act/tc_gact.h b/include/net/tc_act/tc_gact.h
>> index 592a6bc..3067a10 100644
>> --- a/include/net/tc_act/tc_gact.h
>> +++ b/include/net/tc_act/tc_gact.h
>> @@ -2,6 +2,7 @@
>> #define __NET_TC_GACT_H
>>
>> #include <net/act_api.h>
>> +#include <linux/tc_act/tc_gact.h>
>>
>> struct tcf_gact {
>> 	struct tcf_common	common;
>> @@ -15,4 +16,19 @@ struct tcf_gact {
>> #define to_gact(a) \
>> 	container_of(a->priv, struct tcf_gact, common)
>>
>> +#ifdef CONFIG_NET_CLS_ACT
>> +static inline bool is_tcf_gact_dropped(const struct tc_action *a)
> 
> Meybe would be better to name this "is_tcf_gact_shot" for consistency?
> 

Agreed, its probably best to be consistent here. Thanks.
