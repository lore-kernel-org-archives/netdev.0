From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] fq_codel: Fair Queue Codel AQM
Date: Sat, 12 May 2012 00:16:16 +0200
Message-ID: <1336774576.31653.289.camel@edumazet-glaptop>
References: <1336744796.31653.164.camel@edumazet-glaptop>
	 <CABa6K_Fk07CUR1+hOx06cwJ5MuNYi7vpeLYFOc_1Qwmu5ubYhQ@mail.gmail.com>
	 <1336749810.31653.176.camel@edumazet-glaptop>
	 <1336752516.31653.196.camel@edumazet-glaptop>
	 <1336764650.31653.277.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dave Taht <dave.taht@bufferbloat.net>,
	Kathleen Nichols <nichols@pollere.com>,
	Van Jacobson <van@pollere.net>,
	Tom Herbert <therbert@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:46698 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759074Ab2EKWQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 18:16:23 -0400
Received: by weyu7 with SMTP id u7so673303wey.19
        for <netdev@vger.kernel.org>; Fri, 11 May 2012 15:16:22 -0700 (PDT)
In-Reply-To: <1336764650.31653.277.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-11 at 21:30 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>

...

> +static int fq_codel_dump_class_stats(struct Qdisc *sch, unsigned long cl,
> +				     struct gnet_dump *d)
> +{
> +	struct fq_codel_sched_data *q = qdisc_priv(sch);
> +	u32 idx = cl - 1;
> +	struct gnet_stats_queue qs = { 0 };
> +	struct tc_fq_codel_xstats xstats;
> +
> +	WARN_ON_ONCE(1);
> +	if (idx < q->flows_cnt) {
> +		const struct fq_codel_flow *flow = &q->flows[idx];
> +		const struct sk_buff *skb = flow->head;

Oh well, I forgot to remove this WARN_ON_ONCE(1)
