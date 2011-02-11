From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-2.6] ixgbe: fix panic due to uninitialied pointer
Date: Fri, 11 Feb 2011 14:41:21 -0800
Message-ID: <1297464081.3544.72.camel@jtkirshe-MOBL1>
References: <1297460747-31896-1-git-send-email-andy@greyhouse.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-29we2B1ygSOEuB1d+tJa"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15184 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758270Ab1BKWlV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 17:41:21 -0500
In-Reply-To: <1297460747-31896-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-29we2B1ygSOEuB1d+tJa
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-02-11 at 13:45 -0800, Andy Gospodarek wrote:
> Systems containing an 82599EB and running a backported driver from
> upstream were panicing on boot.  It turns out hw->mac.ops.setup_sfp is
> only set for 82599, so one should check to be sure that pointer is set
> before continuing in ixgbe_sfp_config_module_task.  I verified by
> inspection that the upstream driver has the same issue and also added
> a
> check before the call in ixgbe_sfp_link_config.
>=20
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> ---
>  drivers/net/ixgbe/ixgbe_main.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)=20

Thanks Andy!  Have added the patch (with fixed subject) to my ixgbe
queue of patches.

--=-29we2B1ygSOEuB1d+tJa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNVbsRAAoJECTsCADr/EWUd9EH/Aysk4zW9fRGdOZRWFaUwzQx
kZCc/biqd7zbtOdIWp6CWreThysIRe5vk/V3MSi2P3CIp1uJlHruNpn0d0x6rqCr
DV15s/tNw25dG4fF2sYt9jPOnNZlv+knMPPpmB/f7Ci/+w7tUCyAS3IvgY98lgBS
zLFyaFqvDCDp8g3FU6uhKDH6/DIrQ4kXU6CZRNcawp8CW4XVaDwLB64b9H1omTpl
I9/m7NwB/Nan/BxuJ3r+KfeoDXBuKt1JwzeV+n4N5cwOXy901YjYJihXjbYbuqgz
SMlZO60nM9W2iy5a6HhmeS/5ErsQHuLHH6T7lxLilHrgSItcMK2nGc/hTxgEfBo=
=9D0A
-----END PGP SIGNATURE-----

--=-29we2B1ygSOEuB1d+tJa--

