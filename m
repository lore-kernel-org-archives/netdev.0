From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 2/5][SOCK]: Introduce a percpu inuse
 counters array (v2).
Date: Fri, 28 Mar 2008 16:40:24 -0700 (PDT)
Message-ID: <20080328.164024.209852324.davem@davemloft.net>
References: <47ECE58E.5030407@openvz.org>
	<47ED283D.9040902@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51111
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755559AbYC1Xka convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 19:40:30 -0400
In-Reply-To: <47ED283D.9040902@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 28 Mar 2008 18:17:49 +0100

> Pavel Emelyanov a =E9crit :
> > And redirect sock_prot_inuse_add and _get to use one.
> >
> > As far as the dereferences are concerned. Before the patch we made
> > 1 dereference to proto->inuse.add call, the call itself and then
> > called the __get_cpu_var() on a static variable. After the patch we=
=20
> > make a direct call, then one dereference to proto->inuse_idx and=20
> > then the same __get_cpu_var() on a still static variable. So this=20
> > patch doesn't seem to produce performance penalty on SMP.
> >
> > This is not per-net yet, but I will deliberately make NET_NS=3Dy ca=
se
> > separated from NET_NS=3Dn one, since it'll cost us one-or-two more=20
> > dereferences to get the struct net and the inuse counter.
> >
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> >
> >  =20
>=20
> Acked-by: Eric Dumazet <dada1@cosmosbay.com>

Applied.
