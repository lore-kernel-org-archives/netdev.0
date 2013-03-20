From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 0/3] net/intel: Add missing calls to dma_mapping_error
Date: Tue, 19 Mar 2013 17:46:58 -0700
Message-ID: <1363740418.2069.50.camel@jtkirshe-mobl>
References: <1363429925-12724-1-git-send-email-christoph.paasch@uclouvain.be>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-y4uPuKwrRa9UFajXkFdi"
Cc: Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38774 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754491Ab3CTArH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 20:47:07 -0400
In-Reply-To: <1363429925-12724-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-y4uPuKwrRa9UFajXkFdi
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-03-16 at 11:32 +0100, Christoph Paasch wrote:
> After dma_map_single/page, dma_mapping_error must be called.
>=20
> Christoph Paasch (3):
>   e1000: ethtool: Add missing dma_mapping_error-call in
>     e1000_setup_desc_rings
>   ixgb: Add missing dma_mapping_error-call in ixgb_alloc_rx_buffers
>   e1000e: Add missing dma_mapping_error-call in
>     e1000_alloc_jumbo_rx_buffers
>=20
>  drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 14 +++++++++++---
>  drivers/net/ethernet/intel/e1000e/netdev.c       |  7 ++++++-
>  drivers/net/ethernet/intel/ixgb/ixgb_main.c      |  7 ++++++-
>  3 files changed, 23 insertions(+), 5 deletions(-)=20

Thanks Christoph, I will add the series to my queue.

--=-y4uPuKwrRa9UFajXkFdi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRSQcCAAoJEOVv75VaS+3OzP8P/Rt9w8y6gAgcqnXF20PijUQ3
V4lS2jt80CcaCASAfkJAZ3dzehIzXcHZFqRi7MFeSvX6vgZwdCSZvdE2Z++NW42d
sf+oi/l/UfRj1t6k4XvIMOSE2Y6gU1CIMWlHEVH4ZRI9mJfnXAHzUaOsKmjFuLo3
AqgZpJWBG5sd/u0XzaTpmQzV+z/rt0VTB5eoQFOSZPU4d7Sphwu4UIuD2eAcjaZT
LxrZxW18Ex+AjCsAyeYveDpBViSOyUHW01tyMBYBWrsyqYe+rmG1s1TMPgwmCLr/
HYSdhRuwZR9eYO/hFWyAJukLAxJCprnoRPlpZ0D53a9Uudsjour0s7UgE9JRYrga
mtkjO4WDvQ/Ue2E9hO4+wgsV2aBWwShYHKNGAWIQsaN/QTgd2kBqvBOrYOtBpfFi
vmFtjd7UpP31SAacMhqvgr3ouDlvYNQlKG3f33c+7VzkSVIMzMNhDNTtvuiZ651k
H1XSL1EuM867kcFz4tt/ICCO5BHeDtCtxr028uBYGUurVppcMo+Nm1mvFEbnI3mL
PWTGHFzOKYBX7BXC1R2aYBoevGr6qs+a6duJB0PXmhfUGXrK2JERO7b9pvdP3zy7
tl2DEfEhlwhqvelDFI7JgbHnA8ocxVJuxuYaTYGdLCZCX69762ey7reBpWwKaiPE
WVepTTq2mAHwB2KY3o2f
=99fd
-----END PGP SIGNATURE-----

--=-y4uPuKwrRa9UFajXkFdi--
