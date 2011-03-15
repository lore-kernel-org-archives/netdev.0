From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bloat] shaper team forming up
Date: Wed, 16 Mar 2011 00:00:47 +0100
Message-ID: <1300230047.2565.32.camel@edumazet-laptop>
References: <5BC42741-852B-4699-BA5D-D70B8D610D96@gmail.com>
	 <1300134277.2649.19.camel@edumazet-laptop>
	 <1300164166.2649.70.camel@edumazet-laptop>
	 <20110315.155305.71104836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chromatix99@gmail.com, d@taht.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61633 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753222Ab1COXA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 19:00:56 -0400
Received: by bwz15 with SMTP id 15so1048350bwz.19
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 16:00:55 -0700 (PDT)
In-Reply-To: <20110315.155305.71104836.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 mars 2011 =C3=A0 15:53 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 15 Mar 2011 05:42:46 +0100
>=20
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index 6ed6603..fabfe81 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -171,7 +171,7 @@ static struct dst_ops ipv4_dst_ops =3D {
> > =20
> >  const __u8 ip_tos2prio[16] =3D {
> >  	TC_PRIO_BESTEFFORT,
> > -	ECN_OR_COST(FILLER),
> > +	ECN_OR_COST(BESTEFFORT),
> >  	TC_PRIO_BESTEFFORT,
> >  	ECN_OR_COST(BESTEFFORT),
> >  	TC_PRIO_BULK,
> >=20
> >=20
>=20
> Eric can you please formally submit this fix?  I'd like to apply it s=
oon.
>=20
> Thanks.

Sure, I can do this right now, but I want to fully credit Dan Siemon on
this one, as the author of the patch.


