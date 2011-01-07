From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/12][pull-request] Intel Wired LAN Driver Updates
Date: Thu, 06 Jan 2011 16:37:09 -0800
Message-ID: <1294360629.2622.28.camel@jtkirshe-MOBL1>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-RckLjdt/PcE8d/zdV0dA"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59443 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751725Ab1AGAh7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 19:37:59 -0500
In-Reply-To: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-RckLjdt/PcE8d/zdV0dA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-01-06 at 16:29 -0800, Kirsher, Jeffrey T wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> The following series contains ixgbe/e1000e cleanups and fixes.  The
> addition of CE4100 support in e1000, and ixgb VLAN conversion to the
> new model.
>=20
> The following changes since commit dbbe68bb12b34f3e450da7a73c20e6fa1f85d6=
3a:
>=20
>   Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/da=
vem/net-2.6
>=20
> are available in the git repository at:
>=20
>   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6.git m=
aster
>=20
> Alexander Duyck (3):
>   ixgbe: cleanup flow director hash computation to improve performance
>   ixgbe: further flow director performance optimizations
>   ixgbe: update ntuple filter configuration
>=20
> Bruce Allan (6):
>   e1000e: cleanup variables set but not used
>   e1000e: convert calls of ops.[read|write]_reg to e1e_[r|w]phy
>   e1000e: properly bounds-check string functions
>   e1000e: use either_crc_le() rather than re-write it
>   e1000e: power off PHY after reset when interface is down
>   e1000e: add custom set_d[0|3]_lplu_state function pointer for 82574
>=20
> Dirk Brandewie (1):
>   e1000: Add support for the CE4100 reference platform
>=20
> Emil Tantilov (1):
>   ixgb: convert to new VLAN model
>=20
> Yi Zou (1):
>   ixgbe: make sure per Rx queue is disabled before unmapping the
>     receive buffer
>=20
>  drivers/net/e1000/e1000_hw.c      |  328 +++++++++++++----
>  drivers/net/e1000/e1000_hw.h      |   59 +++-
>  drivers/net/e1000/e1000_main.c    |   35 ++
>  drivers/net/e1000/e1000_osdep.h   |   19 +-
>  drivers/net/e1000e/82571.c        |   77 ++++-
>  drivers/net/e1000e/e1000.h        |    3 +
>  drivers/net/e1000e/es2lan.c       |    4 +-
>  drivers/net/e1000e/ethtool.c      |   54 ++-
>  drivers/net/e1000e/hw.h           |    1 +
>  drivers/net/e1000e/ich8lan.c      |   77 ++---
>  drivers/net/e1000e/lib.c          |    3 +-
>  drivers/net/e1000e/netdev.c       |   53 ++--
>  drivers/net/e1000e/phy.c          |   40 +--
>  drivers/net/ixgb/ixgb.h           |    2 +-
>  drivers/net/ixgb/ixgb_ethtool.c   |   35 ++
>  drivers/net/ixgb/ixgb_main.c      |   54 +--
>  drivers/net/ixgbe/ixgbe.h         |   21 +-
>  drivers/net/ixgbe/ixgbe_82599.c   |  749 +++++++++++++++----------------=
------
>  drivers/net/ixgbe/ixgbe_ethtool.c |  142 +++++---
>  drivers/net/ixgbe/ixgbe_main.c    |  169 ++++++---
>  drivers/net/ixgbe/ixgbe_type.h    |   91 +++--
>  21 files changed, 1182 insertions(+), 834 deletions(-)
>=20

I apologize, I fat fingered Andy Gospodarek's email address.  I have
corrected it in this response.

--=-RckLjdt/PcE8d/zdV0dA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNJmA0AAoJECTsCADr/EWUmvIH/Rx0B4q537b6dHtMMP0E7hnb
kXTh6GeP5bEd6tAjHTZshuekF8ZgnX6vcbpyM+CtXSoEeD6mzmj8jGW5q7NJFZCm
5cgm07IyPstl6CUrRv7zOzZ26PBb1l9O4jCLqj3kp15C0gDPW+XydcDzQNjfBnFR
xJmReRV+GsR/uSs40cTXSGm862WKZ9Iq8K2L8w0KJQTy0EZH0M63+mqEH3oKTd4z
c/zah7eXQ20V8kimIeinjZwTcxHjqX5/facjSuNxuN94er4+NjyAzEmUrI8msA0+
WVBCukPsAUeo6Hi3eSnbWtV6mDySBrt0X9fC+yHwtERu4FK1pF1X9N18++laVkA=
=2nQi
-----END PGP SIGNATURE-----

--=-RckLjdt/PcE8d/zdV0dA--

