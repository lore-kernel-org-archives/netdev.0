From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2] ixgb: Don't check for vlan group on transmit.
Date: Wed, 03 Nov 2010 07:55:27 -0700
Message-ID: <1288796127.3663.0.camel@jtkirshe-MOBL1>
References: <1288464591-31528-1-git-send-email-jesse@nicira.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-m9HLanwFZcJ5qXZLYQIF"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56527 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752616Ab0KCOz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Nov 2010 10:55:28 -0400
In-Reply-To: <1288464591-31528-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-m9HLanwFZcJ5qXZLYQIF
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2010-10-30 at 11:49 -0700, Jesse Gross wrote:
>=20
> On transmit, the ixgb driver will only use vlan acceleration if a
> vlan group is configured.  This can lead to tags getting dropped
> when bridging because the networking core assumes that a driver
> that claims vlan acceleration support can do it at all times.  This
> change should have been part of commit eab6d18d "vlan: Don't check for
> vlan group before vlan_tx_tag_present." but was missed.
>=20
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> ---
>  drivers/net/ixgb/ixgb_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)=20

Thanks Jesse, I have added this to my queue.

--=-m9HLanwFZcJ5qXZLYQIF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJM0XfWAAoJECTsCADr/EWUfWAIALKmZxGTBvWNcE6WE/9b6AAW
aetnWDi3cUczwxvLllcUwPosYxjjd5Rs2KaqdqQBGypnH//wEt43cYUjpTLhwyXJ
WfxvjgnC0Ytfc49jbnLAak+4K4VVNsQuG+nqRF1MT312uC8/FiszP4kiFdlPqufi
6OvIeinBarA85dFx3fjWuCIezpfBBbTGnwT7+vlfBZlKFy7sIQjnkOWcWd2nXs6g
Lr1fSL5NI1J6b72FeiVzVQHZ2G9wRuhVuqrPhCgQ4Iyj51fecXgMHS3c3M8JZOCt
riVX9CAcwCDiUyfYJ+BLrXoJAb8WD/kHYl4dXgFUT1polP2wmEEQ3CaS3id9rHA=
=UdUl
-----END PGP SIGNATURE-----

--=-m9HLanwFZcJ5qXZLYQIF--

