From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH v2 7/8] net: mvmdio: add xmdio support
Date: Fri, 9 Jun 2017 08:40:19 +0200
Message-ID: <20170609064019.GB31464@kwain>
References: <20170608092653.25221-1-antoine.tenart@free-electrons.com>
 <20170608092653.25221-8-antoine.tenart@free-electrons.com>
 <20170608160331.GA20216@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="U+BazGySraz5kW0T"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:54216 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751501AbdFIGkb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 02:40:31 -0400
Content-Disposition: inline
In-Reply-To: <20170608160331.GA20216@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--U+BazGySraz5kW0T
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Thu, Jun 08, 2017 at 06:03:31PM +0200, Andrew Lunn wrote:
> On Thu, Jun 08, 2017 at 11:26:52AM +0200, Antoine Tenart wrote:
> > +#define MVMDIO_XSMI_MGNT_REG		0x0
> > +#define  MVMDIO_XSMI_READ_VALID		BIT(29)
> > +#define  MVMDIO_XSMI_BUSY		BIT(30)
> > +#define MVMDIO_XSMI_ADDR_REG		0x8
> > +#define  MVMDIO_XSMI_PHYADDR_SHIFT	16
> > +#define  MVMDIO_XSMI_DEVADDR_SHIFT	21
> > +#define  MVMDIO_XSMI_READ_OPERATION	(0x7 << 26)
> > +#define  MVMDIO_XSMI_WRITE_OPERATION	(0x5 << 27)
>=20
> These two operations seem odd. Generally ops have the same shift.

Indeed, this is odd. I'll have a look at this.

Thanks,
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--U+BazGySraz5kW0T
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZOkLTAAoJEFxNi8it27zYD8sP/iXgFtoS0147lsyqvxw0k8/c
fCuT5jDX9ZZcrodbyu0aQcfluMpuyFaXFR6zsIILXNoNdTCy2dTLFHWQXIU1uXS3
AZhUAxtwh8t5TQ/tfa88+aqRP5r0Wu0aksE/x507zVGWg8oMzhlg8vQ0q4R5hVtH
Jh1kWAn0fHkUExTStEC1R8ViVycSUz7g+2DQwWH5Zk13GflokEeFDL0pYCHL6Xy5
KuKFdxe2+ioK0b6iFaWxDdGbjerCYbGj4rtSCGc4tInmrQigcm8kUFSkkj2QmDEs
8Wdnytk8QVkuaj8HTWKd4Z03Fj+GBkwG/EoZcBE+0XCRPmqjs8HHob073PA098Da
Nv6y4qL9VAHF9HdAkdIcCsT9DPZkAAkh93FElmRDLdhGFXa2IgnSlFL1e8fCjZX+
RllJ0fOFnYLoAOW8TiDZW1SDhdNdto0xwk5Ld49zTY9ecbxTHwkemX1L6WmsHxqi
vJ2F7xoaidyPZEsla8mTfwq7x3NEK/aDVQAwTLbWvglirfV5ytjbZvlYPU3lWS54
hbI/JLyG8n6tLUQkc6qDs893H2KK+SyxYp+FUUg5artgiQKWkV67bafqSIfCkCQX
GGfEyS9+/uUSz6s3zagQ93h918yZFB1bm03eHHFo553y5ejzmptTKdqd3z62G6p3
VypoZntaNTa9fWHca6E0
=gDzh
-----END PGP SIGNATURE-----

--U+BazGySraz5kW0T--
