From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 4/6] pkt_sched: Add qdisc->ops->peek() implementation.
Date: Thu, 16 Oct 2008 14:26:33 +0200
Message-ID: <48F732F9.8010806@trash.net>
References: <20081016094804.GE19019@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65244 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113AbYJPM0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 08:26:38 -0400
In-Reply-To: <20081016094804.GE19019@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Add qdisc->ops->peek() implementation for work-conserving qdiscs.
> 
> diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
> index 915f314..155648d 100644
> --- a/net/sched/sch_multiq.c
> +++ b/net/sched/sch_multiq.c

I haven't looked at sch_multiq in detail yet, but isn't it supposed to
be used as root qdisc? In that case we wouldn't need a ->peek operation.

> diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
> index d35ef05..8d7acd8 100644
> --- a/net/sched/sch_teql.c
> +++ b/net/sched/sch_teql.c

teql is also meant to be used as root qdisc. It doesn't seem to enfore
it though.
