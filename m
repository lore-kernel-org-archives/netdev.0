From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 3/8] net: sched: add cls_u32 offload hooks
 for netdevs
Date: Tue, 16 Feb 2016 19:21:29 -0800
Message-ID: <56C3E739.9040903@gmail.com>
References: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810> <20160216060125.32452.25924.stgit@john-Precision-Tower-5810> <20160216202049.GC2246@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: amir@vadai.me, jhs@mojatatu.com, davem@davemloft.net,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35367 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755530AbcBQDVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 22:21:45 -0500
Received: by mail-pa0-f50.google.com with SMTP id ho8so3138436pac.2
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 19:21:45 -0800 (PST)
In-Reply-To: <20160216202049.GC2246@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-16 12:20 PM, Jiri Pirko wrote:
> Tue, Feb 16, 2016 at 07:01:25AM CET, john.fastabend@gmail.com wrote:
>> This patch allows netdev drivers to consume cls_u32 offloads via
>> the ndo_setup_tc ndo op.
>>
>> This works aligns with how network drivers have been doing qdisc
>> offloads for mqprio.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> 
> <snip>
> 
>> +struct tc_cls_u32_hnode {
>> +	u32 handle;
>> +	u32 prio;
>> +	unsigned int divisor;
>> +};
>> +
>> +enum {
> 
> Please name enum and ...
> 
>> +	TC_CLSU32_NEW_KNODE,
>> +	TC_CLSU32_REPLACE_KNODE,
>> +	TC_CLSU32_DELETE_KNODE,
>> +	TC_CLSU32_NEW_HNODE,
>> +	TC_CLSU32_REPLACE_HNODE,
>> +	TC_CLSU32_DELETE_HNODE,
>> +};
>> +
>> +struct tc_cls_u32_offload {
>> +	/* knode values */
>> +	int command;
> 
> ... use it here instead of "int"
> 

Yep thanks. I'll go ahead and do this now.
