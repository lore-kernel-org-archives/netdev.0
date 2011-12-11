From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] drivers/net: use IS_ENABLED(CONFIG_IPV6)
Date: Sat, 10 Dec 2011 16:51:36 -0800
Message-ID: <1323564696.29470.6.camel@joe2Laptop>
References: <4EE32777.2030003@parallels.com>
	 <4EE327CB.4040505@parallels.com> <1323514931.4016.17.camel@edumazet-laptop>
	 <20111210.131555.2025649575447940902.davem@davemloft.net>
	 <1323546511.4016.32.camel@edumazet-laptop>
	 <1323554422.29470.4.camel@joe2Laptop>
	 <1323556174.4016.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:60886 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751084Ab1LKAvh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Dec 2011 19:51:37 -0500
In-Reply-To: <1323556174.4016.35.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-12-10 at 23:29 +0100, Eric Dumazet wrote:
> Le samedi 10 d=C3=A9cembre 2011 =C3=A0 14:00 -0800, Joe Perches a =C3=
=A9crit :
> > Instead of testing defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODU=
LE)
[]
> > diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/eth=
ernet/broadcom/cnic.c
[]
> > @@ -3516,7 +3516,7 @@ static int cnic_get_v4_route(struct sockaddr_=
in *dst_addr,
> >  static int cnic_get_v6_route(struct sockaddr_in6 *dst_addr,
> >  			     struct dst_entry **dst)
> >  {
> > -#if defined(CONFIG_IPV6) || (defined(CONFIG_IPV6_MODULE) && define=
d(MODULE))
> > +#if IS_ENABLED(CONFIG_IPV6)
>=20
> Are you sure this is equivalent ?

I believe so.

KBUILD add -DMODULE to the compile options when
building for modules.
