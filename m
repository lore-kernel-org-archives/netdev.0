From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [patch] e1000e, igbvf: fix default message level
Date: Sat, 10 Mar 2012 01:02:15 -0800
Message-ID: <1331370135.27038.0.camel@jtkirshe-mobl>
References: <20120310084921.GA4647@elgon.mountain>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-mq93A5xiD+QxCVWGHWVc"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30764 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752704Ab2CJJC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2012 04:02:26 -0500
In-Reply-To: <20120310084921.GA4647@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-mq93A5xiD+QxCVWGHWVc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2012-03-10 at 11:49 +0300, Dan Carpenter wrote:
> The intent here was to enable both NETIF_MSG_DRV and NETIF_MSG_PROBE
> messages, but in the original code only the NETIF_MSG_DRV bit was set.
>=20
> NETIF_MSG_DRV and NETIF_MSG_PROBE are bits 0 and 1, they are not
> supposed to be used to do a shift.  I think the confusion is because
> the msg_enable can also be controlled through ethtool which passes a
> bit
> number that is used to do a bit shift.
>=20
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>=20

Thanks Dan!  I will add the patch to my queue.

--=-mq93A5xiD+QxCVWGHWVc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPWxiXAAoJEOVv75VaS+3O0NQP/jHa4lgbviikdJFI6hL68Oi6
qjWZyXZh4vTuz5sOaveK957lSOa0ECy0RqaTW2UpmZHdhKvYC/CqFP85feihINCe
5DNCs9HGDKYd7g34bcb0ImPH9XRUvc08kyrCUiHz8WL1f0HAJjcomyXDWvYs//V4
R3W9iArLDJM+P2ECeU/3cWOg+vEzbZqVUNaUyOv4whTsh+ZQhNcva9tuYlbTo3N6
N6/myMvJkupTOU72j7aFHiHXwIHnVBzwp7YKYwzx0daLh0Li1LbhFpc3q9n1WJFU
IgWwbeOZGwvPgvlnhEMo2UBZ3KKps0uf1FVGV8BgBMRBMD3zCw31YG7fXnThxfyl
Wuzd8cvjiInITY0jGB5yW6+vwuzoofvYrS9jWOsoCEI6Mj6Vz7V3ViuAjXsHrK8P
lFV30Tj0wdT0No4Ykkp2FmBZ8YQo8E+sYISeH+yLsDSPkj9MhPngLrFmrKI5rotz
38oyGfqQ6e+xcVnY9H6QPSBlVe/esSHermxOXQIPwLz5a4qGU6stV7C5v+dyo0pD
xyc7Gw+2AAwTQuXblUp7J3PURdSl764EYoXF54ZTk/NDu25uOr3HPNeeSc9gcy0Z
U2mTDfAiZsRVz3Y+pS8nlAxSgpDqOWHcTDlVrjeYCJ6a2jkOOWQmndnkWCERLxvS
vXgWxRydJAuRJPMOPkSX
=x47f
-----END PGP SIGNATURE-----

--=-mq93A5xiD+QxCVWGHWVc--
