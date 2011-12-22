From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next V2] igb: add basic runtime PM support
Date: Wed, 21 Dec 2011 16:57:20 -0800
Message-ID: <1324515440.2327.25.camel@jtkirshe-mobl>
References: <4EF16CC2.80806@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-C4Z9QQ0AK3xF3vjrq0l6"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net,
	"davem@davemloft.net" <davem@davemloft.net>,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com, rjw@sisk.pl
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17065 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752157Ab1LVA5W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Dec 2011 19:57:22 -0500
In-Reply-To: <4EF16CC2.80806@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-C4Z9QQ0AK3xF3vjrq0l6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-12-21 at 13:21 +0800, Yan, Zheng wrote:
> Use the runtime power management framework to add basic runtime PM
> support
> to the igb driver. Namely, make the driver suspend the device when the
> link
> is off and set it up for generating a wakeup event after the link has
> been
> detected again. This feature is disabled by default.
>=20
> Based on e1000e's runtime PM code.
>=20
> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
> ---
> Changes since v1:
> Don't suspend the device when shutting down the interface.
> Avoid race between runtime suspending and ethtool operations.
>=20
>  drivers/net/ethernet/intel/igb/igb_ethtool.c |   16 +++
>  drivers/net/ethernet/intel/igb/igb_main.c    |  136
> ++++++++++++++++++++++----
>  2 files changed, 133 insertions(+), 19 deletions(-)=20

I have applied this to my queue of patches.  Thanks Zheng!

--=-C4Z9QQ0AK3xF3vjrq0l6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJO8oBwAAoJEOVv75VaS+3OK0IP/20ustJ/a9YEGKnJOWki5aJf
E59bK4wKW1ZnwrmWTIH2B0kNMtMfsr7yGlHkJfdbrHpkDetzhSHHYXyH/IzcOlLO
5JMeEP22pRWZP5rEl7BGh1EOC7D4MzQRDic9qhEdclRo29KwgI5RaV1+eIKvVwmO
AxpeJffNe68PAGnFI7//4op0z7vLt8KMeRJIVtf+S+0yWe5E1Q2U9ZQfHiAtdtAM
WG+SNQ2HVeTrKyRWI0ZuN4+V21kOlWvokjA0WXjmDV0CDaE8fkQ4iKD4bg8kxpld
jufnSQm8TMmVvp10EsAH7qscSbYrZfyV3e3/8WMS3d5gRQztpnWqJX3HQwwtWhQS
B2igD9D5PBY1wjAX5+Sp0oH4nQ5JYex/C5MFhi3T8NWK/qsPJTUT+1EGu/HiEhw5
yOXqdKMwChYq0YQJPCPQVkSln0JhRJXriKCK3NSuurYNQuM2I8EkXUhxYPCYZ9Rh
CG9KiOfn/MgTcqwNVCbdQsac6LmiUFf8DaCJxVxS6xMuWvfBdbgwDT8vAMrvN7JP
vOIu2iLHjgXFLzyk80rtMl2J1dZ02NdiYWBQ/JHTVgpKzNonhCnuzKA0wzAW45i3
Fte+J1YvTdKOqvwWNpWE0Xp5CRNRQ/WnhqkLKHH75FX/2Q3Tb4s0c6YjTbw8IssP
SfZv8dudHJzjSF3fTsBR
=ANyM
-----END PGP SIGNATURE-----

--=-C4Z9QQ0AK3xF3vjrq0l6--
