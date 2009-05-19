From: Sascha Hlusiak <contact@saschahlusiak.de>
Subject: Re: [PATCH 5/5] sit: stateless autoconf for isatap
Date: Wed, 20 May 2009 00:57:10 +0200
Message-ID: <200905200057.11287.contact@saschahlusiak.de>
References: <1242767023-9501-3-git-send-email-contact@saschahlusiak.de> <1242767023-9501-5-git-send-email-contact@saschahlusiak.de> <20090519.143523.74697967.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:50935 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754266AbZESWz6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 18:55:58 -0400
In-Reply-To: <20090519.143523.74697967.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +	spin_lock(&ifp->lock);
> > +	for (addr =3D ifp->addr_list; addr; addr =3D addr->if_next) {
>
> You posted the same broken patch again!
>
> net/ipv6/sit.c: In function =E2=80=98ipip6_tunnel_rs_timer=E2=80=99:
> net/ipv6/sit.c:235: warning: passing argument 1 of =E2=80=98_spin_loc=
k=E2=80=99 from
> incompatible pointer type net/ipv6/sit.c:256: warning: passing argume=
nt 1
> of =E2=80=98__raw_spin_unlock=E2=80=99 from incompatible pointer type
>
> This isn't rocket science. :-/
Sorry, I overlooked I had CONFIT_DEBUG_SPINLOCK unset so the above line=
s=20
weren't even compiled.

I'm really sorry for all the noise and hope the latest resent patchset =
is=20
finally correct. Thanks for your work.

