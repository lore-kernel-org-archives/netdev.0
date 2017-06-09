From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH v2 7/8] net: mvmdio: add xmdio support
Date: Fri, 9 Jun 2017 08:39:34 +0200
Message-ID: <20170609063934.GA31464@kwain>
References: <20170608092653.25221-1-antoine.tenart@free-electrons.com>
 <20170608092653.25221-8-antoine.tenart@free-electrons.com>
 <a60a0b26-62b1-7c9e-e846-215747dddb1f@gmail.com>
 <20170608165546.GC20216@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="/9DWx/yDrRhgMJTb"
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
        mw@semihalf.com, linux@armlinux.org.uk,
        linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:54184 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751505AbdFIGjq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 02:39:46 -0400
Content-Disposition: inline
In-Reply-To: <20170608165546.GC20216@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--/9DWx/yDrRhgMJTb
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello Florian, Andrew,

On Thu, Jun 08, 2017 at 06:55:46PM +0200, Andrew Lunn wrote:
> On Thu, Jun 08, 2017 at 09:42:21AM -0700, Florian Fainelli wrote:
> > On 06/08/2017 02:26 AM, Antoine Tenart wrote:
> > > This patch adds the xMDIO interface support in the mvmdio driver. This
> > > interface is used in Ethernet controllers on Marvell 370, 7k and 8k (=
as
> > > of now). The xSMI interface supported by this driver complies with the
> > > IEEE 802.3 clause 45 (while the SMI interface complies with the clause
> > > 22). The xSMI interface is used by 10GbE devices.
> >=20
> > In the previous version you were properly defining a new compatibles
> > strings for xmdio, but now you don't and instead you runtime select the
> > operations based on whether MII_ADDR_C45 is set in the register which is
> > fine from a functional perspective.
> >=20
> > If I get this right, the xMDIO controller is actually a superset of the
> > MDIO controller and has an extra MVMDIO_XSMI_ADDR_REG register to
> > preform C45 accesses?
> >=20
> > If that is the case (and looking at patch 8 that seems to be the case),
> > you probably still need to define a new compatible string for that
> > block, because it has a different register layout than its predecessor.
>=20
> Yes, i think you need the compatible string to return -EOPNOSUP when
> somebody tries to do a C45 access on the older IP which only has C22.

That's a very good point. I'll update the series to fix this.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--/9DWx/yDrRhgMJTb
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZOkKjAAoJEFxNi8it27zYW28P/AmR6vWQymGCW8+tbnHn8i01
mHLtTAOEgxGFUDVZMqXtawCaee68xstMLbxE1q0kuHFY4VzNrKUKtiLaeHyn47nq
SQ+VTkfodLi6knSQJi01bzhAZY9kkQ1nhtFG7AaFUlIbGzGJCfneWFGkm+lDrObw
6PWfqLJSbCMdhnGQY/EoOWUNHXFBSQpheUcNhuC+nNSPgSQJiK+kK+wI6KPtzgDX
u5ncHzDUbMrLOsWBbVf+vBd+RY0I8fY6W2lXNpO03TeslLaa+J+D/VR47mXkXxJ8
/0zd7atHEoawM5lQHlxu6EEkB9VNlU1AwGNS14NkEZ/+VwcXGNrqiM7kEQ3K2c6+
BuKfQbSvZy/j9aaBIdLqJC5O+2sK31M5xhYccDy7wGUebgffvwN79u9AKngs76U0
x8gzZBjl0rSvJxVTcVDqdJP7kB5I3xRbmrIjQ9hAxGwxnpeQCL37FWBUfH4yjUx6
it2ZeFTAX1A6JvDLEiQanomhn984yAVkxCEtVzSOP3x/7Y1YgXNuFJqtZfurtygN
khLHn3bPT54WZMI49iaM9Gx9XV7xhdZle9MsU4RjHbul81jdzs9njt8LKvtPC4U2
YGv7HAm5j1J5beQ0ip/ea8gySxGpjuwigFwg/AJwmB2vFtnBviFQBdIAYss0di65
gYEadFYa2JuCYPTtuS6n
=/t+d
-----END PGP SIGNATURE-----

--/9DWx/yDrRhgMJTb--
