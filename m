From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] pkt_sched: gen_estimator: Dont report fake rate
	estimators
Date: Fri, 2 Oct 2009 07:17:17 +0000
Message-ID: <20091002071717.GB9694@ff.dom.local>
References: <20091002070819.GA9694@ff.dom.local> <4AC5A7F9.3000005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:37263 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753481AbZJBHRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 03:17:20 -0400
Received: by fxm27 with SMTP id 27so747560fxm.17
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2009 00:17:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4AC5A7F9.3000005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 02, 2009 at 09:12:57AM +0200, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
>=20
> > To make my point clare: why not something like this?:
> >=20
> > static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 =
clid,
> >                          u32 pid, u32 seq, u16 flags, int event)
> > {
> > 	...
> > 	if (gnet_stats_copy_basic(&d, &q->bstats) < 0 ||
> > 	    (gen_estimator_active(&q->bstats, &q->rate_est) &&
> >              gnet_stats_copy_rate_est(&d, &q->rate_est) < 0) ||
> >             gnet_stats_copy_queue(&d, &q->qstats) < 0)
> >                 goto nla_put_failure;
> >=20
> > BTW, I'm not sure we need to chanage user visible API for this.
> > (Is it really expected to work after updating gen_stats.h only in
> > iproute?)
> >=20
>=20
> Thats would be better indeed, do you want to work on it or let me do =
it ?

I want you work on it.

Thanks,
Jarek P.
