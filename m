From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH resend net-next 1/2] net_sched: replace pr_warning with
 pr_warn
Date: Mon, 23 Dec 2013 15:39:56 +0800
Message-ID: <52B7E8CC.50605@huawei.com>
References: <1387760778-25256-1-git-send-email-yangyingliang@huawei.com>	 <1387760778-25256-2-git-send-email-yangyingliang@huawei.com> <1387761616.22671.40.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:53409 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730Ab3LWHlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 02:41:22 -0500
In-Reply-To: <1387761616.22671.40.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/23 9:20, Joe Perches wrote:
> On Mon, 2013-12-23 at 09:06 +0800, Yang Yingliang wrote:
>> Prefer pr_warn(... to pr_warning(...
> 
> Couple of trivial comments:
> 
>> diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
> []
>> @@ -303,8 +303,8 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
>>  		 * and don't need yet another qdisc as a bypass.
>>  		 */
>>  		if (p->mask[index] != 0xff || p->value[index])
>> -			pr_warning("dsmark_dequeue: unsupported protocol %d\n",
>> -				   ntohs(skb->protocol));
>> +			pr_warn("dsmark_dequeue: unsupported protocol %d\n",
>> +				ntohs(skb->protocol));
> 
> When converting messages with embedded function names,
> consider using "%s: ...", __func__
> 
>> diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
> []
>> @@ -370,8 +370,8 @@ static inline int gred_change_table_def(struct Qdisc *sch, struct nlattr *dps)
>>  
>>  	for (i = table->DPs; i < MAX_DPs; i++) {
>>  		if (table->tab[i]) {
>> -			pr_warning("GRED: Warning: Destroying "
>> -				   "shadowed VQ 0x%x\n", i);
>> +			pr_warn("GRED: Warning: Destroying "
>> +				"shadowed VQ 0x%x\n", i);
> 
> When converting formats split across multiple lines,
> please coalesce the format fragments like:
> 
> 			pr_warn("GRED: Warning: Destroying shadowed V0 0x%x\n",
> 				i);
> 
> 
> 
> 

OK, thanks!
