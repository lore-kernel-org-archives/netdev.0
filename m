From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 03/10] seeq: Move the SEEQ drivers
Date: Fri, 04 Nov 2011 14:42:53 -0700
Message-ID: <1320442974.5386.14.camel@jtkirshe-mobl>
References: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1313134384-7287-4-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20111104172446.GB12913@n2100.arm.linux.org.uk>
	 <1320441367.2113.4.camel@Joe-Laptop>
	 <20111104212555.GD12913@n2100.arm.linux.org.uk>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-lx0qwMk/MCxqzG3gIrBe"
Cc: Joe Perches <joe@perches.com>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Hamish Coleman <hamish@zot.apana.org.au>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48817 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752214Ab1KDVmz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 17:42:55 -0400
In-Reply-To: <20111104212555.GD12913@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-lx0qwMk/MCxqzG3gIrBe
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-11-04 at 14:25 -0700, Russell King - ARM Linux wrote:
> On Fri, Nov 04, 2011 at 11:16:07PM +0200, Joe Perches wrote:
> > On Fri, 2011-11-04 at 17:24 +0000, Russell King - ARM Linux wrote:
> > > Okay, this is the only patch I saw (for the SEEQ drivers), but I noti=
ce
> > > that more of the ARM drivers have moved.  The result is not nice.  Or
> > > even workable.
> > >=20
> > > While looking for my ether1, ether3 and etherh drivers in Kconfig, I
> > > enable every option which is presented to me under the new 'ethernet
> > > drivers' stuff.  I'm offered my ether3 driver under the SEEQ stuff -
> > > that's fine.  But what about the rest?
> > []
> > > While I realise this is a big change, and bugs like this are likely, =
it
> > > would've been nice to be copied on more of the patches which affect
> > > drivers I maintain.
> >=20
> > Hi Russell.
> >=20
> > What drivers in drivers/net do you maintain?
> >=20
> > I believe this is the list in MAINTAINERS for you:
> >=20
> > ARM/EBSA110 MACHINE SUPPORT
> > F:      drivers/net/ethernet/amd/am79c961a.*
> > ARM/RISCPC ARCHITECTURE
> > F:      drivers/net/ethernet/i825xx/ether1*
> > F:      drivers/net/ethernet/seeq/ether3*
> >=20
> > Are there others? If yes, what are they?
>=20
> If that's what's in mainline, then etherh has been dropped from that
> list through this move.  It's drivers/net/ethernet/8390/etherh*, so
> that needs adding back for "ARM/RISCPC ARCHITECTURE".
>=20
> It was correct - below seems to be what happened...
>=20
> commit 115978859272b958366d4a08c99a24f9625fa663
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Wed Jul 13 15:38:08 2011 -0700
>=20
>     i825xx: Move the Intel 82586/82593/82596 based drivers
>=20
> @@ -1014,7 +1014,7 @@ F:        arch/arm/include/asm/hardware/ioc.h
>  F:     arch/arm/include/asm/hardware/iomd.h
>  F:     arch/arm/include/asm/hardware/memc.h
>  F:     arch/arm/mach-rpc/
> -F:     drivers/net/arm/ether*
> +F:     drivers/net/arm/ether3*
>=20
> That change was probably correct at the time, because this one which
> came before it:
>=20
> commit 644570b830266ff33ff5f3542b9c838f93a55ea6
> Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date:   Sat Apr 2 06:20:12 2011 -0700
>=20
>     8390: Move the 8390 related drivers
>=20
> which moved the etherh driver without updating MAINTAINERS for that
> change.

This was my bad.  There was a lot of discussion and shuffling of drivers
early on to make sure we have the drivers in the right location, and I
initially had all the drivers/net/arm/ether* drivers in the same
location.  I can put together a patch to resolve this if no one has one
in the works.

Sorry about that Russell.

--=-lx0qwMk/MCxqzG3gIrBe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJOtFxdAAoJEOVv75VaS+3OoKAP/3jT63NG1aYPIBwnr46+K5sw
yNVjMTaVMqgzhA/p6XFiPmYBgSpISfTLDOtu62JOtAE1ymAHLbeSVax2ftFR+xid
1U4NpM/94+s66AsndmoKFmtXYygzeCk8gbW1lnoCx8WauAZh8w07t2Ftp+vpoh4N
nOBmi+F+MBgJ98PFPi45eY/8IBb0w1W0VQSCBUL0YCQPDjd5U2V/CR3lPHnzmmaL
CNTaiyplyMBB1cjJZlq5Y8FQcfJ5cRDwjzES4FmJTRNk4jP0IOWNaOt4KLJhBfEA
6cgBREFJApFqlTGGBST/cfoi8+nBiKrcMJQB4HL5X9Rqat7/Z+Df6XeotIjZ7mfw
SxQI/ek3NFTX5CY5UonreUJYs7B90Mle50xZu4YlB9znpa8Mt/C1R445aFCnZQZ1
6TneSE8vQjwzf4WeKhSISBNVM2gq0uFrOpPiFZuAVb2f1gue5SCrbd9Cemz5EiFu
lbC39T+aJ5MLBQT4g2y4bPx7V0Qu9cnCn9fSSuRSc/dcSCuiuLrHtcKcW2LQmhxe
dLgUFzYpj4Xq/tYkcXTyWHtdBO4ihNATml5AIsrioorT5CYkejV1xwtmSPdS66U3
azPpDMWcsKdTv4MLnVY20JM0j7wkBmxaKT1G5R+6mXCLmaSolOIhkYulk08EVfEV
i3gldFq3RXxXhYFyYBvU
=kR+B
-----END PGP SIGNATURE-----

--=-lx0qwMk/MCxqzG3gIrBe--
