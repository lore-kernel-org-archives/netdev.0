From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH RFC] ixgbe: Module param "allow_any_sfp" for allowing
 unsupported SFP+ modules
Date: Thu, 19 Jan 2012 17:12:14 -0800
Message-ID: <1327021934.2707.10.camel@jtkirshe-mobl>
References: <1326886258.19261.25.camel@probook>
	 <20120118091351.000052fc@unknown>  <m3d3ag7ki8.fsf@ursa.amorsen.dk>
	 <1326925160.2795.45.camel@probook> <1326984405.2795.91.camel@probook>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-OeAJceuZz593ZFBT5Gyl"
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Benny Amorsen <benny+usenet@amorsen.dk>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Ben Greear <greearb@candelatech.com>,
	"Fujinaka, Todd" <todd.fujinaka@intel.com>,
	David Lamparter <equinox@diac24.net>,
	Robert Bays <robert@herjulf.net>,
	"Ronciak, John" <john.ronciak@intel.com>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:26030 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751367Ab2ATBMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 20:12:25 -0500
In-Reply-To: <1326984405.2795.91.camel@probook>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OeAJceuZz593ZFBT5Gyl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-01-19 at 15:46 +0100, Jesper Dangaard Brouer wrote:
>=20
> Intel are limiting which SFP's can use in their NICs, due to support
> issues.
> This restriction comes from an EEPROM setting
> IXGBE_DEVICE_CAPS_ALLOW_ANY_SFP.
> This is for example the case with the 10Gbit/s X520-DA2 NIC.
>=20
> Add a module param "allow_any_sfp", which can override the EEPROM
> setting, and allows any unsupported SFP+ module to be used.  When
> doing so, print disclaimer of unsupported usage.
>=20
> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c |   23
> ++++++++++++++++++++---
>  1 files changed, 20 insertions(+), 3 deletions(-)=20

Thanks Jesper, I will add it to me queue of patches.

--=-OeAJceuZz593ZFBT5Gyl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPGL9uAAoJEOVv75VaS+3OzHgP+gJzzzWBx460R/F1bQXi8Xhf
0OnL2IoRXB3pCsy5CT1KAvFzxybin9o4NQzXXMdkZ0YFHVNV9RnrfrVJ24M/NX6q
VA5rbo+GHthkGlBgDc6u27P/5zrUI/fHz58NExRpYIGg8oWi92SyjvuWmNblx1B8
vwHxJzmVO+3/CKCJpZ69X8i4DwKqe2A4fklw3NpeLUl+/QaLVDYxHQY9tet4fV8i
TSwcL7hsXWnsRQHY0O79wZUd5fT37dPoilulpm05Qa+VlFwsbmH6SVwPLBm79lR4
FGafzEPBZAYIdGMrD9+XLTlZM4OSfbmBX/UaK+aaPtN8ERHdgzNwzaUg3SkfYBlq
eFFCRzf8G+nm6B/jnK0NwJazkXx3cbm3F8FYXMZePJLH1MEsB5H+2Qws+yfDBijt
IQ6xZzwgD9o5LcuCChpEY+shGUAIkfazRxYrBHF81OWcyThk583vDxw+xzUQ/fOj
XGG1PLhn8z1heHeI/dRbLRMmCwSjwNeGBSa8SoqTPRMNZBqGJk8ukCKkbqxujnFk
FPEyl+/tJgO1ODREh5t+bY/yayDFUz/B6FmoAKFgS4K49YddlJvlyjlx6O7AATEU
TbvYoH1EfWAl6W0PKssTkqcyj0u7f8HiE6OZgQdhgixf6UQWe/DhkjOU1I+UanqT
KUo9KthaH+wst1j8pig3
=Owx8
-----END PGP SIGNATURE-----

--=-OeAJceuZz593ZFBT5Gyl--
