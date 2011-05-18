From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug, kernel panic, NULL dereference , cleanup_once /
 icmp_route_lookup.clone.19.clone / nat , 2.6.39-rc7-git11
Date: Wed, 18 May 2011 13:44:07 +0200
Message-ID: <1305719047.2991.4.camel@edumazet-laptop>
References: <54ec5cd14e5e5c76aa06c2e6899299ce@visp.net.lb>
	 <41a1892fed59b411bb08d3ecb0d8cda5@visp.net.lb>
	 <1305711471.2983.27.camel@edumazet-laptop>
	 <0a630bbf006d1210220a6ba4d55c5804@visp.net.lb>
	 <1305713111.2991.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:46970 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932763Ab1ERLoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 07:44:11 -0400
Received: by fxm17 with SMTP id 17so1119778fxm.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 04:44:10 -0700 (PDT)
In-Reply-To: <1305713111.2991.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 mai 2011 =C3=A0 12:05 +0200, Eric Dumazet a =C3=A9crit :
> Le mercredi 18 mai 2011 =C3=A0 12:53 +0300, Denys Fedoryshchenko a =C3=
=A9crit :
>=20
> >  Yes, i will try. I should enable SLUB debugging only, or also anyt=
hing=20
> >  else?
> >=20
> >  But possible it will take time to reproduce bug, seems it is occur=
ing=20
> >  rare. With 2.6.39 release i will rollout update to few hundreds PP=
PoE's,=20
> >  maybe it will increase chances to get information.
> >=20
>=20
> I would try both : slub_debug=3DZFP slub_nomerge
>=20
> or maybe only slub_debug=3DZFPU
>=20
> Thanks !
>=20

Hmm, do you have both ipv6/ipv4 trafic on your machine by any chance ?




