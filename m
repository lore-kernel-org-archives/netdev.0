From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: RE: [PATCH net-next] igb: Add support for byte queue limits.
Date: Tue, 03 Jan 2012 02:15:58 -0800
Message-ID: <1325585758.2428.13.camel@jtkirshe-mobl>
References: <1324480695.2301.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111221.144207.1402252938319338463.davem@davemloft.net>
	 <9BBC4E0CF881AA4299206E2E1412B626011AB6@ORSMSX102.amr.corp.intel.com>
	 <1325570866.2874.10.camel@edumazet-laptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ihrUwO2+Sl4ML/08rpLC"
Cc: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:63305 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751347Ab2ACKQA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jan 2012 05:16:00 -0500
In-Reply-To: <1325570866.2874.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ihrUwO2+Sl4ML/08rpLC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-01-03 at 07:07 +0100, Eric Dumazet wrote:
> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 21:17 +0000, Wyborny, Carolyn a =
=C3=A9crit :
> >=20
> > >-----Original Message-----
> > >From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.or=
g]
> > >On Behalf Of David Miller
> > >Sent: Wednesday, December 21, 2011 11:42 AM
> > >To: eric.dumazet@gmail.com
> > >Cc: netdev@vger.kernel.org; Kirsher, Jeffrey T; Duyck, Alexander H
> > >Subject: Re: [PATCH net-next] igb: Add support for byte queue limits.
> > >
> > >From: Eric Dumazet <eric.dumazet@gmail.com>
> > >Date: Wed, 21 Dec 2011 16:18:15 +0100
> > >
> > >> This adds support for byte queue limits (BQL)
> > >>
> > >> Since this driver collects bytes count in 'bytecount' field, use it
> > >also
> > >> in igb_tx_map()
> > >>
> > >> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > >> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > >> CC: Alexander Duyck <alexander.h.duyck@intel.com>
> > >
> > >Intel folks, you got this?
> > >--
> > >To unsubscribe from this list: send the line "unsubscribe netdev" in
> > >the body of a message to majordomo@vger.kernel.org
> > >More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >=20
> > Yes, although many are out for the holidays.=20
> >=20
> > ACK.  We'll get it into our queue for testing.
>=20
> Any news on this patch ?
>=20
> I would like it being added for next merge window.
>=20
> By the way I did test it on my machine.
>=20
> Thanks
>=20

Yes, it passed testing, so I will push it in my next series of patches.
Just waiting on the current series to be accepted before I push it.

--=-ihrUwO2+Sl4ML/08rpLC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPAtVeAAoJEOVv75VaS+3O4CYQAJNfIVDlnYQ2YvInZlhA+gx3
+SjEQNM+ixbCw5h4MvvbIh/Y4hfSaCFzMYWx6Uv10A1V4Mva0GGO0sOXOv28GNd0
ch/e6acSdAdUCTF//575gL6NtCYfMie+JKMQb0YL0Kwbc1brFkHCmOIDBVblEpzP
tfRljHzryiXfNEomhK0/XvSiCv37YjR1GjWIb77MIlcNor6lp/oSyx7hR1wgib9b
wZNwm0cyN2Blx+ZmYGCONBJIOseu2mt6sZZc5fPans6jxpc2vdhtjuB6bRcnMWCx
RU9CGpyjYf7vpfSIUnIAxEOcKRnb1J3r1RbZ6U6shdlLKtQ1d8zAzFOlyoN83MIE
j1j810wXu+y45U0fdi/5rUO/Bhp8sEJyLWFbrwW9DRFCyyTtXOfpPIXJ2q0d9tsk
OFRsJGsZrJaLSLmL7BZYRarfq27blwtkwl5svBz70NwhCf57XP75iSFcVClsj3jk
1XXKAdYWOGwMropZh66mErttKpl+btbn4H2U6qumoVgctezMQkbxkdHirIb74b18
/JYilEBxC/c/a3uK7nUvbMfbNzkM79Zn0ZloEZj/3Nf2e2u1qY/ULsFBpOUZarra
PV7N2kJv4xeICI0z+KHTLSFrT+7UgQbUSJOarnbL4EKwrA6r/LGXhjvgjeHIVJ34
uX4ItkdFQ6RZcXvaZ9Pg
=/tlC
-----END PGP SIGNATURE-----

--=-ihrUwO2+Sl4ML/08rpLC--
