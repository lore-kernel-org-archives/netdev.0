From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: [PATCH] fs_enet: restore promiscuous and multicast settings in restart()
Date: Thu, 26 Jun 2008 11:38:03 +0200
Message-ID: <200806261138.04192.laurentp@cse-semaphore.com>
References: <200806181707.17739.laurentp@cse-semaphore.com> <200806201025.28768.laurentp@cse-semaphore.com> <8496f91a0806200155hcb1f440ld7b5f678d95fdb85@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart14464927.ITozZ45xa8";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "Bill Fink" <billfink@mindspring.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, pantelis.antoniou@gmail.com,
	vbordug@ru.mvista.com
To: matvejchikov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:60213 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754320AbYFZJiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 05:38:07 -0400
In-Reply-To: <8496f91a0806200155hcb1f440ld7b5f678d95fdb85@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart14464927.ITozZ45xa8
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

On Friday 20 June 2008 10:55, Matvejchikov Ilya wrote:
> >> > diff --git a/drivers/net/fs_enet/mac-fcc.c=20
b/drivers/net/fs_enet/mac-fcc.c
> >> > index ce40cf9..1a95cf1 100644
> >> > --- a/drivers/net/fs_enet/mac-fcc.c
> >> > +++ b/drivers/net/fs_enet/mac-fcc.c
> >> > @@ -464,6 +464,9 @@ static void restart(struct net_device *dev)
> >> >             C32(fccp, fcc_fpsmr, FCC_PSMR_FDE | FCC_PSMR_LPB);
> >> >
> >> >     S32(fccp, fcc_gfmr, FCC_GFMR_ENR | FCC_GFMR_ENT);
> >> > +
> >> > +   /* Restore multicast and promiscous settings */
> >> > +   set_multicast_list(dev);
> >> >  }
>=20
> Is it right to call set_multicast_list() after turning on transmitter
> and receiver? May be swap this lines around?

I'm not sure if that will make a difference, but you're right, restoring th=
e=20
multicast and promiscuous settings is better done before turning the receiv=
er=20
and transmitter on.

I'll send a new patch.

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart14464927.ITozZ45xa8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBIY2N88y9gWxC9vpcRAuljAKDD41t9uE4oXuG1MrkOpDgsxRXV2gCfRXeH
cGP4eVG5ixNwDAQpQfE6ozI=
=8Y7q
-----END PGP SIGNATURE-----

--nextPart14464927.ITozZ45xa8--
