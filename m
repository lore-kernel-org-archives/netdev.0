From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 09/13] net: mvpp2: dynamic reconfiguration of
 the PHY mode
Date: Thu, 24 Aug 2017 19:13:01 +0200
Message-ID: <20170824171301.GH28443@kwain>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-10-antoine.tenart@free-electrons.com>
 <20170824145609.GJ8022@lunn.ch>
 <20170824155241.GF28443@kwain>
 <20170824160124.GA18700@lunn.ch>
 <20170824161945.GG28443@kwain>
 <20170824165743.GB18700@lunn.ch>
 <20170824170401.GA20805@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="J/zg8ciPNcraoWb6"
Cc: Andrew Lunn <andrew@lunn.ch>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, kishon@ti.com, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux-kernel@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:48406 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753952AbdHXRND (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 13:13:03 -0400
Content-Disposition: inline
In-Reply-To: <20170824170401.GA20805@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--J/zg8ciPNcraoWb6
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 24, 2017 at 06:04:01PM +0100, Russell King - ARM Linux wrote:
> On Thu, Aug 24, 2017 at 06:57:43PM +0200, Andrew Lunn wrote:
> > > I see what could be the issue but I do not understand one aspect thou=
gh:
> > > how could we switch from one PHY to another, as there's only one outp=
ut
> > > between the SoC (and so a given GoP#) and the board. So if a given PHY
> > > can handle multiple modes I see, but in the other case a muxing
> > > somewhere would be needed? Or did I miss something?
> >=20
> > I think we need a hardware diagram...
> >=20
> > How are the RJ45, copper PHY, SFP module connected to the SoC?
> >=20
> > Somewhere there must be a mux, to select between copper and
> > fibre. Where is that mux?
>=20
> In the 88x3310 PHY:
>=20
>                      .------- RJ45
> MVPP2 ----- 88x3310 PHY
>                      `------- SFP+

And the "MVPP2" part can be expended to:

        .-- GoP #0 --.
MVPP2 ----- GoP #1 ---- Comphy lane #X -- 88x3310
        `-- GoP #2 --'

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--J/zg8ciPNcraoWb6
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmfCR0ACgkQXE2LyK3b
vNgiTQ/+Lk2bon1hHYq+bdUnqW1XA2Ke3NzFpLgSCXQ7e6oRCR1vfa2AJDg52JKH
YZi58gZpOAcaTV2sBcco9Tg8T7HYI3kMZr02JlK34RzN2tWgL+Tqrybl2O5GYtSk
VtfK9C9LluGFqq7+7xFsF/VcrgvTfdXoryBnRzPcdlWdBG8sEhTYwpuHt2wozk76
0pmA1vGaqh0QOuVRazwzW3aPOyEYkcrkA8of7xvXODn/m7Xa1GYx7L9OpEq4o2zP
bYbrlHvelWaN5v5agWre6zOoXkKz1Xh3M3I/cFrAHy4UhRgxUrS4QVIe+pkmb6gB
nI6e9Jwl7AA8h1FSfxIIroBFk3V+Q/CC1VGHccc05gLPKKUvIu6+Bd0t1EVAe0MG
yUknb981g2hJaN/S4EYlvL4I+IzZJ6m3e/f0UKb6Bk9drsNu5WiCOdjSAhrx06t8
kBnSJ1q5FwV2eFHN/LRGBT3tiRaUkGMInJYOy6vTBuoiRWbOX4k07S4i5Fc1XnHM
d71XDwg/sRt7VnOeVwC0JwMd/kffOsIgZwUKB7EYCDRzZGcJeiCIh2KYPSjKv8Ov
CtxzoNPG6w2IiDXA2pdZWAHaythS0IOaw/5tMpGubpV2UFP4hC+HMiMB7klbECPT
pejMQCMWx/inNFOlXBmng1Jw/35PtT5VmW8cayyVj63x/Pa+M1k=
=TAth
-----END PGP SIGNATURE-----

--J/zg8ciPNcraoWb6--
