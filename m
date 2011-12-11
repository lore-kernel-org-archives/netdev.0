From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] drivers/net: use IS_ENABLED(CONFIG_IPV6)
Date: Sun, 11 Dec 2011 09:52:55 +0100
Message-ID: <1323593575.4016.38.camel@edumazet-laptop>
References: <4EE32777.2030003@parallels.com>
	 <4EE327CB.4040505@parallels.com> <1323514931.4016.17.camel@edumazet-laptop>
	 <20111210.131555.2025649575447940902.davem@davemloft.net>
	 <1323546511.4016.32.camel@edumazet-laptop>
	 <1323554422.29470.4.camel@joe2Laptop>
	 <1323556174.4016.35.camel@edumazet-laptop>
	 <1323564696.29470.6.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:62779 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929Ab1LKIxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2011 03:53:00 -0500
Received: by eaaj10 with SMTP id j10so93085eaa.19
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2011 00:52:59 -0800 (PST)
In-Reply-To: <1323564696.29470.6.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 10 d=C3=A9cembre 2011 =C3=A0 16:51 -0800, Joe Perches a =C3=A9=
crit :
> On Sat, 2011-12-10 at 23:29 +0100, Eric Dumazet wrote:
> > Le samedi 10 d=C3=A9cembre 2011 =C3=A0 14:00 -0800, Joe Perches a =C3=
=A9crit :
> > > Instead of testing defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MO=
DULE)
> []
> > > diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/e=
thernet/broadcom/cnic.c
> []
> > > @@ -3516,7 +3516,7 @@ static int cnic_get_v4_route(struct sockadd=
r_in *dst_addr,
> > >  static int cnic_get_v6_route(struct sockaddr_in6 *dst_addr,
> > >  			     struct dst_entry **dst)
> > >  {
> > > -#if defined(CONFIG_IPV6) || (defined(CONFIG_IPV6_MODULE) && defi=
ned(MODULE))
> > > +#if IS_ENABLED(CONFIG_IPV6)
> >=20
> > Are you sure this is equivalent ?
>=20
> I believe so.
>=20
> KBUILD add -DMODULE to the compile options when
> building for modules.
>=20
>=20

You didnt answer my question or you dont understand your change.

I wonder why.

Point was : IPV6 compiled as a module, and _this_ driver compiled
staticaly.

Did you tried this combination ?
