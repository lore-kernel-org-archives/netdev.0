From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] sched: QFQ - quick fair queue scheduler
Date: Fri, 7 Jan 2011 20:02:34 -0800
Message-ID: <20110107200234.3f5e7ff8@nehalam>
References: <20110106195614.20dbc402@nehalam>
	<AANLkTi=pqZ3CwLTAZnhd-cyQNj8OSeBHsP_bFiH3hJ-_@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	netdev@vger.kernel.org, Luigi Rizzo <rizzo@iet.unipi.it>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47605 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752385Ab1AHECl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 23:02:41 -0500
In-Reply-To: <AANLkTi=pqZ3CwLTAZnhd-cyQNj8OSeBHsP_bFiH3hJ-_@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 8 Jan 2011 10:56:33 +0800
Changli Gao <xiaosuo@gmail.com> wrote:

> > + =A0 =A0 =A0 cl->bstats.packets +=3D skb_is_gso(skb)?skb_shinfo(sk=
b)->gso_segs:1; =20
>=20
> Hmm, there is no other packets schedulers which account packets in
> this way. Which one is better? I am not sure. And in this patch,
> qstats.drops isn't maintained in the same way. Would these two be
> consistent.

HTB uses this accounting.

