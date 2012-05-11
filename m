From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] fq_codel: Fair Queue Codel AQM
Date: Fri, 11 May 2012 18:17:21 -0400 (EDT)
Message-ID: <20120511.181721.2127370946821555231.davem@davemloft.net>
References: <1336752516.31653.196.camel@edumazet-glaptop>
	<1336764650.31653.277.camel@edumazet-glaptop>
	<1336774576.31653.289.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org,
	dave.taht@bufferbloat.net, nichols@pollere.com, van@pollere.net,
	therbert@google.com, mattmathis@google.com, ycheng@google.com,
	shemminger@vyatta.com, maze@google.com, nanditad@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37314 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422631Ab2EKWSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 18:18:32 -0400
In-Reply-To: <1336774576.31653.289.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 12 May 2012 00:16:16 +0200

> On Fri, 2012-05-11 at 21:30 +0200, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
> 
> ...
> 
>> +static int fq_codel_dump_class_stats(struct Qdisc *sch, unsigned long cl,
>> +				     struct gnet_dump *d)
>> +{
>> +	struct fq_codel_sched_data *q = qdisc_priv(sch);
>> +	u32 idx = cl - 1;
>> +	struct gnet_stats_queue qs = { 0 };
>> +	struct tc_fq_codel_xstats xstats;
>> +
>> +	WARN_ON_ONCE(1);
>> +	if (idx < q->flows_cnt) {
>> +		const struct fq_codel_flow *flow = &q->flows[idx];
>> +		const struct sk_buff *skb = flow->head;
> 
> Oh well, I forgot to remove this WARN_ON_ONCE(1)

I can do it.
