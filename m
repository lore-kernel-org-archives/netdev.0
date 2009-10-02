From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] pkt_sched: gen_estimator: Dont report fake rate estimators
Date: Fri, 02 Oct 2009 09:12:57 +0200
Message-ID: <4AC5A7F9.3000005@gmail.com>
References: <20091002070819.GA9694@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55813 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757306AbZJBHM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 03:12:56 -0400
In-Reply-To: <20091002070819.GA9694@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :

> To make my point clare: why not something like this?:
>=20
> static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 cl=
id,
>                          u32 pid, u32 seq, u16 flags, int event)
> {
> 	...
> 	if (gnet_stats_copy_basic(&d, &q->bstats) < 0 ||
> 	    (gen_estimator_active(&q->bstats, &q->rate_est) &&
>              gnet_stats_copy_rate_est(&d, &q->rate_est) < 0) ||
>             gnet_stats_copy_queue(&d, &q->qstats) < 0)
>                 goto nla_put_failure;
>=20
> BTW, I'm not sure we need to chanage user visible API for this.
> (Is it really expected to work after updating gen_stats.h only in
> iproute?)
>=20

Thats would be better indeed, do you want to work on it or let me do it=
 ?

Thanks
