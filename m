From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [EXT] Re: [PATCH net-next 10/18] net: mvpp2: use the GoP
 interrupt for link status changes
Date: Wed, 23 Aug 2017 18:04:44 +0200
Message-ID: <20170823160444.GC23960@kwain>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-11-antoine.tenart@free-electrons.com>
 <20170726162648.GK12049@lunn.ch>
 <20170823082510.GD5202@kwain>
 <5ebd192c54984b25adda0a294035b1b9@IL-EXCH01.marvell.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="tqI+Z3u+9OQ7kwn0"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        Andrew Lunn <andrew@lunn.ch>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "jason@lakedaemon.net" <jason@lakedaemon.net>,
        "gregory.clement@free-electrons.com"
        <gregory.clement@free-electrons.com>,
        "sebastian.hesselbarth@gmail.com" <sebastian.hesselbarth@gmail.com>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        "linux@armlinux.org.uk" <linux@armlinux.org.uk>,
        "mw@semihalf.com" <mw@semihalf.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Stefan Chulski <stefanc@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:40755 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932161AbdHWQEp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 12:04:45 -0400
Content-Disposition: inline
In-Reply-To: <5ebd192c54984b25adda0a294035b1b9@IL-EXCH01.marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--tqI+Z3u+9OQ7kwn0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 23, 2017 at 03:24:55PM +0000, Stefan Chulski wrote:
> > When the cable is connected (there is signal) and the serdes is in sync=
 and AN
> > succeeded.
> >=20
> > > With SFF/SFP ports, you generally need a gpio line the fibre module
> > > can use to indicate if it has link. Fixed-phy has such support, and
> > > your link_change function will get called when the link changes.
> >=20
> > So that would work when using SFP modules but I wonder if the GoP irq i=
sn't
> > needed when using passive cable, in which case this patch would still b=
e needed
> > (and of course we should support the new Russell phylib capabilities).
>=20
> Even if new phylib driver supports passive direct cables connection,=20
> GoP IRQ required for SOHO/Peridot external switch support.
> SOHO/Peridot external switch could be connected directly to Serdes line.

So I guess the GoP link irq patches are needed. Should I resend them
then?

We'll have to discuss how to handle fixed-phy vs GoP IRQ, but I guess we
can do this when adding the fixed-phy support later.

Thanks,
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--tqI+Z3u+9OQ7kwn0
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmdp5wACgkQXE2LyK3b
vNji2A/9FhRiYip33dtfdw2ynvJ9lroeXISwc2OOo+QuOlNm1SrnPmc+fuhpFfGG
IMGfuUDl6mK1ZV6IqbVJ1jo1rVhHW7QHmTuuPFhDeWKgEUhnhCEZHBapkKNmGxo0
6gfta2eOsYzwVvoHgtHsQXTaOa6VxOvnmOGMbg9zit5HSFq/qZP3O1KaHt/tnvox
vV0LV7q6PPW2+m/8noVsrndmVq4a/bd3jhn7e679REHCtj4XkKAlKCkZDyDMOm8d
P2nVsj2UE+N7oLxBX4Z93t2WF67Iw7R4EIC4Ai/mh5rd6mWVmhFN9pJaO3j/1ei5
aKSpGQ4dcNzryihPPKxVzgl2xmk7xaEZQYMx9Yy4nTrMKGMlXrdsrThxBiA+AARd
WHeuG318VimUjz2OquuFqqw1F7K2XLjdb6jWW2YV+Whyhvf2gSnC/XIZLuS9sUS0
cwwpeha/R5p5DmX8Zc+dWwTiFfxzJ0E9RyYrgLmXTu0ZYyeIyb7Wnl38LD2yckD3
BA1k4ziAfcRhR5Enr64F2VjMQFl9wRlcD1PcREeSfQTKltWy4ljb9B+ZDf5DHg7I
oMmz4+RLwL+2uDLNGGCvR+zpbXUc4QUu31qlQPL1AFD1JLikDG2G7I29Hn/wK70l
OZXl8sTHf1Jc0+ysL1G1TEfBT05rEyckx3ibMJbqmniTtRsccY8=
=rv8p
-----END PGP SIGNATURE-----

--tqI+Z3u+9OQ7kwn0--
