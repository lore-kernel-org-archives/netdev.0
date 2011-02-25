From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: Re: [RFC] be2net: add rxhash support
Date: Fri, 25 Feb 2011 15:35:42 -0600
Message-ID: <20110225213542.GA11773@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:19307 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754597Ab1BYVgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 16:36:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> Sent: Friday, February 25, 2011 1:45 PM
> To: Khaparde, Ajit
> Cc: netdev@vger.kernel.org
> Subject: Re: [RFC] be2net: add rxhash support
>=20
> Le vendredi 25 f=C3=A9vrier 2011 =C3=A0 13:36 -0600, Ajit Khaparde a =
=C3=A9crit :
> > > -----Original Message-----
> > > From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> > >
> > > How is it possible ?
> > >
> > > (I have a VLAN config on top of a bonding)
> > >
> > I'm looking at this..
> > There is no switch involved in your test, just back to back?
> >
>=20
> There is a switch.
>=20
> Machines are HP ProLiant BL460c G7
>=20
> But why do you ask ?
>=20

I asked that because, if a switch is part a of the configuration,
the ASIC can receive packets other than the tcp flow.

And if hashing is enabled for IP packets, we can see this behavior.
The other values indicate that hashing has been enabled for IPv4 packet=
s.

Thanks
-Ajit
