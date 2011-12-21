From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] igb: add basic runtime PM support
Date: Tue, 20 Dec 2011 18:02:23 -0800
Message-ID: <1324432943.2327.11.camel@jtkirshe-mobl>
References: <4EEEC688.2010601@intel.com> <4EF0F32F.4040603@intel.com>
	 <4EF13B27.5050809@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-KQxJ4+rByWDrdVtpJ+8c"
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net,
	"davem@davemloft.net" <davem@davemloft.net>,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, rjw@sisk.pl
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27780 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750924Ab1LUCCY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Dec 2011 21:02:24 -0500
In-Reply-To: <4EF13B27.5050809@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KQxJ4+rByWDrdVtpJ+8c
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-12-21 at 09:49 +0800, Yan, Zheng wrote:
> On 12/21/2011 04:42 AM, Alexander Duyck wrote:
> > I am curious on if you have done any testing on an actual igb device
> with this code enabled?  My main concern is that the PHY is integrated
> into these parts, thus putting the MAC into D3 will result in
> behaviour changes in the PHY.  Specifically in the case of D3 the PHY
> on many of the igb parts will go into a low power link up mode, and
> may exclude a 1Gb/s link.  If this occurs I would expect to see a
> number of link issues on the device.
> >=20
> I tested the code on a 82576 dual ports adapter, didn't noticed any
> issue.
>=20
> > From what I can tell it looks like if you were to perform any
> ethtool operations while the link is down and this code is enabled it
> would likely result in multiple errors.  I am not sure what would
> happen if you were to run an "ethtool -t" test while the device was in
> a powered down state.
> >=20
> This is not big problem because netif_device_detach() is called when
> suspending a device. "ethtool -t" reports "No such device" if the
> device is suspended. (There is a bug my patch, it doesn't calls
> netif_device_detach() if the device is down. Will send a new patch
> later)=20

I will hold off on adding this patch to my queue of patches since you
intend to send a v2 of the patch.

Thanks Zheng!

--=-KQxJ4+rByWDrdVtpJ+8c
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJO8T4vAAoJEOVv75VaS+3OJHoP+QE1AgXUfe+ibOQBaaGt5BTw
fM7iop/JECE5RupFB5Ek8qlcM2zTRRnY/1L8Jx7xW5Y3hYsNJROEEhhVjOBLfzKd
6+aXWnWB/JJvZ9TWSs40MT5QLezalx//g1uIZvqlQtvWaLqoH70iy7As+qZbZTaG
dI8PQm3WLmPWD6UY4mAIJ9bn/AHnjOU4G862MkGeG7AFx8Z5XST7zzSvkLXiKXAw
D03k+CtRY9fEJzqqMx7rXsLyg41kOnghm2IoqJoqgPRcEXcAPbMtRFkH+XttsGu+
uKErhTnFwGRVIVb6zTIltSxWaU349VkCLqo5XwTN84ePZ2htx3l7xyGWuDOMA1KR
sqjtOKMkKLIZC+jzsMasV/hsqjWg9ZGzWHfZzHYmOLfZP0J3wRIL4YgN22LmZOhW
rHfdoLOSOUsZ3UX+Ca+j6tUrWWd4X1HG3jgck5iIAXOvnhx00SjHzBvn3d9hSDLA
JH/U1zOb0OdlmQ90zXoyQl8P3qmfeE1dgUkXXWCFBfcy5lLJofezfiMA1xbzheQM
MP5AV1cZWcew4mtePGaAmJ56TcYRnaq3Les90Wvf6ELL3Tj0rwRYshws1F57pBXC
y7jbKkxh0zaqv4cvzTqPdareiRTbNNd1zkrx1XYtObar+IblUYr7ccSWyu20ipT6
vr28IKO0yPROM4vy6D9g
=9Zsp
-----END PGP SIGNATURE-----

--=-KQxJ4+rByWDrdVtpJ+8c--
