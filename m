From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH 0/2] Follow-ups for GUEoIPv6 patches
Date: Wed, 18 May 2016 14:27:58 -0700
Message-ID: <1463606878.2713.68.camel@intel.com>
References: <20160518173605.2608.42484.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-wXFCKciWEnuWgY2BZ2G6"
To: Alexander Duyck <aduyck@mirantis.com>, tom@herbertland.com,
	alexander.duyck@gmail.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, kernel-team@fb.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:18142 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752009AbcERV2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2016 17:28:06 -0400
In-Reply-To: <20160518173605.2608.42484.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wXFCKciWEnuWgY2BZ2G6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-05-18 at 10:44 -0700, Alexander Duyck wrote:
> This patch series is meant to be applied after:
> [PATCH v7 net-next 00/16] ipv6: Enable GUEoIPv6 and more fixes for v6
> tunneling
>=20
> The first patch addresses an issue we already resolved in the GREv4 and
> is
> now present in GREv6 with the introduction of FOU/GUE for IPv6 based GRE
> tunnels.
>=20
> The second patch goes through and enables IPv6 tunnel offloads for the
> Intel
> NICs that already support the IPv4 based IP-in-IP tunnel offloads.=C2=A0 =
I
> have
> only done a bit of touch testing but have seen ~20 Gb/s over an i40e
> interface using a v4-in-v6 tunnel, and I have verified IPv6 GRE is still
> passing traffic at around the same rate.=C2=A0 I plan to do further testi=
ng
> but
> with these patches present it should enable a wider audience to be able
> to
> test the new features introduced in Tom's patchset with hardware
> offloads.
>=20
> ---
>=20
> Alexander Duyck (2):
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ip6_gre: Do not allow segmentation offload=
s GRE_CSUM is enabled
> with FOU/GUE
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 intel: Add support for IPv6 IP-in-IP offlo=
ad

Dave, I have this series added to my queue.
--=-wXFCKciWEnuWgY2BZ2G6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXPN5eAAoJEOVv75VaS+3O7EwP/itwEdAWlXzikXH50qKzbc7M
hEKw/1ghJ3aZtp2QxLD/wbfrp3aXiGqGXXZSeOPJ/WgRQnnPv8lx2rKwsQvODYcU
My9xmTDyvFSTDNnTq4+jBG63kTB2y9UZTFm3mjGlNVW8jMmLUAyC/RkJSj3peXyl
On415HKJ8ehq/6Hpu2e902iMnnZRA/M39pYy5GEl0AKu1jM1vw6vS26j5V1ysonC
CLvHvmn+IQ2DWcGQAwbhs4kKtlaj7qOa2xZlD0BkG382E0Cy7SKFwqTPnsvwHmJ6
gHsFmFFzUt17KfuXiuqHwP2KTgpXjIPWaNqZKtmD5lS8iWWS8l+4L5DW4fDMfCq4
2cyAtHUeKN6ODR05d/dHpDnGPCVE1TUhYcZaSETZmZrUUxDeQppR4S3ZFHOqqo88
JDReRdgvqU3tAH0AuBtJ7SUld/AWK7rpWuiVSKM5iJ51LoabnfChYxZyFnd/jPD4
i+CDzA8WwSjL9+/R0IqCaDZeCe4ZeYljSdrsJ95isiGhGHWwpbRzXxnGeUVbBgjj
TWPDL+YrqOu+Ee/ZYg9HUmR8BoeT6Bosz17PIQWQeBZ5Vwm+IWaJSRz3zPiRhzBX
aYAZxN7UQ7hvFRHIRbK2OJPFXXQ91B/BqjJt7AWZRrH/m/M9WtpqZDupOYArC6rz
7Mh6PxRKl7vuU8vLSWML
=GV1A
-----END PGP SIGNATURE-----

--=-wXFCKciWEnuWgY2BZ2G6--
