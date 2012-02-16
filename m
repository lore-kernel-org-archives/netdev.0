From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netem: fix unwanted reordering
Date: Thu, 16 Feb 2012 07:13:06 +0100
Message-ID: <1329372786.5646.7.camel@edumazet-laptop>
References: <1329371375.5646.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37743 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753339Ab2BPGNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 01:13:11 -0500
Received: by wgbdt10 with SMTP id dt10so1622432wgb.1
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 22:13:10 -0800 (PST)
In-Reply-To: <1329371375.5646.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 f=C3=A9vrier 2012 =C3=A0 06:49 +0100, Eric Dumazet a =C3=A9=
crit :
> commit 50612537e9 (netem: fix classful handling) added in typo in
> netem_dequeue() :
>=20
> After checking skb at the head of tfifo queue for time constraints, i=
t
> dequeues tail skb, thus adding unwanted reordering.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/sched/sch_netem.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20

Please dont apply this patch, there is a 2nd issue I must fix as well

(qdisc stats are updated twice)
