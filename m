From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] phonet: use call_rcu for phonet device
 free
Date: Mon, 07 Jun 2010 15:49:43 +0200
Message-ID: <1275918583.2545.84.camel@edumazet-laptop>
References: <20100607132738.GB2730@psychotron.lab.eng.brq.redhat.com>
	 <474f08fed4a406e929af3d4142d3e185@chewa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43812 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711Ab0FGNtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 09:49:47 -0400
Received: by fxm8 with SMTP id 8so2085851fxm.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 06:49:45 -0700 (PDT)
In-Reply-To: <474f08fed4a406e929af3d4142d3e185@chewa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 07 juin 2010 =C3=A0 15:43 +0200, R=C3=A9mi Denis-Courmont a =C3=
=A9crit :
> On Mon, 7 Jun 2010 15:27:39 +0200, Jiri Pirko <jpirko@redhat.com> wro=
te:
> > Use call_rcu rather than synchronize_rcu.
> >=20
> > Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>=20
> This looks fine to me, but what is the goal here? The RCU documentati=
on
> seems to imply that synchronize_rcu() is preferable over call_rcu() w=
hen at
> all possible.
>=20

Thats not exactly that.

synchronize_rcu() is easier, in respect of memory use.
But its drawback is current thread is blocked for several milli seconds=
=2E

In the end, call_rcu() is more scalable.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


