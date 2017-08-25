From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next v2 08/14] net: mvpp2: check the netif is running
 in the link_event function
Date: Fri, 25 Aug 2017 19:09:20 +0200
Message-ID: <20170825170920.GA2568@kwain>
References: <20170825144821.31129-1-antoine.tenart@free-electrons.com>
 <20170825144821.31129-9-antoine.tenart@free-electrons.com>
 <1faa09d8-305a-f6d2-facf-d28f336c849a@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="PEIAKu/WMn1b1Hv9"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, kishon@ti.com, andrew@lunn.ch,
        jason@lakedaemon.net, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47092 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754410AbdHYRJc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 13:09:32 -0400
Content-Disposition: inline
In-Reply-To: <1faa09d8-305a-f6d2-facf-d28f336c849a@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Florian,

On Fri, Aug 25, 2017 at 09:49:15AM -0700, Florian Fainelli wrote:
> On 08/25/2017 07:48 AM, Antoine Tenart wrote:
> > This patch adds an extra check when the link_event function is called,
> > so that it won't do anything when the netif isn't running.
>=20
> Why is this needed? Are you possibly starting the PHY state machine
> earlier than your ndo_open() call? Looking quickly through the driver
> does not suggest this is going on since you properly connect to the PHY
> in mvpp2_open() and start the PHY there.

I added some checks while working on this, and kept this one. But I
looked at the driver again and I assume you're right and the patch could
be dropped.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--PEIAKu/WMn1b1Hv9
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmgWb0ACgkQXE2LyK3b
vNiAWg//ftHSV77hNJC85M8ntQsfJYTSJlFCv8nU/UaH6ijX0KWBmJ4cKniUjzuA
ySukVEPOzNfcW5NcFbpTDBbEhBg4ChDc4emAGJfXZtdahiXTzQw+JbIDNvnd/ggV
vrnDivIKRTzfTbogMi9JdWOmyfWstZ+rfIBSy4f7DHROf5JI+pqL9L/akNqRXLSA
MGsbYjIqommZsO9tLHMgLknPVaBl1JlJqZA2zjZNQcCn3Dmp5SNKYOxdf6s1TcWn
lDb+J5cHWoRZM0nuv2flW5muBvvAM8OZN/dJdW4DVlBi0N1tVOeFNLMh34VYAzgV
BBj2j82Pg9lx9cIF7jkl+HqcSBUof4W/xWyhQq7jp7R6FkuP0LNIwHNOAdPedu8W
3/x1Lltfpv9JJMLyTgiR+qsDgyD+ctoY16DYCJ/uJ6XYSKAUMNz9X/rrj8jKyqd5
8/OCjhsb8EC8FG+Y0J6jSKft2qa7tXospBg9yVklPdJSx+TGD1ncnDyT1aaNKOYO
yWP8N4vBtE0qbaNaxcaqrfZtZU8aedUbONl1YWGJAx421mWSITFjIokTrs1PLk1t
hWiiprnnBgNC4k4CQV/Fl9Ea2HfS83TsTrWNcTsgzVSeS/wVr7NlYPlgiLVoBf8x
XbWvsdlxNhbuuTTQ+0goBnIxS25/9i0LtsOfTkyb0MzyL/EEnzY=
=O37H
-----END PGP SIGNATURE-----

--PEIAKu/WMn1b1Hv9--
