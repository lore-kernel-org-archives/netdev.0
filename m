From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [next PATCH 00/11] ixgbe: Add support for mixed PF/VF
 virtualization
Date: Tue, 03 Nov 2015 04:38:51 -0800
Message-ID: <1446554331.12325.0.camel@intel.com>
References: <20151103005850.28233.63113.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-YG2/Nk2Cq9B3WmwWU+iy"
To: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:42683 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750852AbbKCMjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 07:39:22 -0500
In-Reply-To: <20151103005850.28233.63113.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-YG2/Nk2Cq9B3WmwWU+iy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-11-02 at 17:09 -0800, Alexander Duyck wrote:
> This patch series extends the abilities of the ixgbe driver so that
> we can
> now support VLAN trunking on top of the PF when SR-IOV is enabled.=20
> By
> doing this we are able to extend the existing capabilities that were
> enabled with the "bridge fdb add" support that was added some time
> ago.  It
> had enabled the ability to have PF and VF mixed on a flat network,
> this
> makes it so that it also works on a VLAN enabled network.
>=20
> The first few patches in this series are basically just cleanup.=20
> They
> either fix bugs found in the code, or address complexity that was
> making it
> hard to either read or sort out exactly how the code was supposed to
> work.
>=20
> The second half of the patch set is where we start adding features.
> Specifically with this patch set the VLAN behavior changes for the PF
> in
> two ways.  First we do not need to use the VLVF if the VFs have not
> already
> set up a pool list.  As such I added functionality so that we can
> skip that
> step when it is not needed.  Then I added support for VLAN
> promiscuous by
> simply setting all of the bits in the VFTA and letting the packets
> fall
> through to the default pool.  In addition when in promiscuous mode we
> set
> the pool bit for the PF in all of the VLVF entries.  This way if
> anyone
> adds a new entry it will automatically have the PF enabled.
>=20
> The last few patches address some more issues I found during testing.
>   The
> issues were primarily related to stale entries floating around in
> either
> the RAR or VLVFB registers which were pointing to pools which were
> not
> valid for the given L2 address.

I have added these patches to my queue, Dave.
--=-YG2/Nk2Cq9B3WmwWU+iy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWOKrbAAoJEOVv75VaS+3ODoQP/0ANC4yrG86MSkfopIATN2Lb
ATb02kTNPXBr08HhuTWMGA+5iTShXDNiv3GyVlddi+B/RIF5AbEaVtkuJ6IbSdve
bW4F7DVPPyALQ6N2rpSKYfg1sgd747j97wkJc5WFHm1sg39mN9SEXY+xr11yaCVy
SiWJKV0ADYYDNeWxDd42IPI1BhmERecrTbuH7p6ai8QRITJLjkzdSuRDuUPHI/7T
MMVZR47HGvXrGYuCuusyHwF58RxjOKTfIVdnj/Sa3bIHeVJ9f/5monWK+oh//2S8
Zd+AQrrISV+McwzuEoyKcQ/VVS/AmWvl2cX5Jh+B9a1zFVEqGrKxBYe076qNyCoQ
hKmX1s1lbnmvm3NO1wcsT8UAvyDJa3RzrWKQqo9ozdGaCKd4vjg6AsUSJMJzCOI/
7A6AEbS15GvviuwVTYuV8ib8MKauxzK7cs2n0UJABvtMWYWn1x0zc9pT8nqzzia9
2i+YMkPgFXK/cNY1vuVGWGm0jLDBiRPtw6SAzMTr1t1oyCAXC93WTczhQHxpPvfR
vrI6AUxMv2UDt1WNpTTCunPYzHGKSybm/PhSgayHe/SyNhrWnCH4h5vF8y4HHwyr
Jq/Dnd9ywcn2eVTrJU1cv5Ryw/Dkmr816X1bP4lMgVFurrODxZrP3xoJ6hrbi1Jy
qrvRVEn2e+jr/C6LLxzz
=OhIm
-----END PGP SIGNATURE-----

--=-YG2/Nk2Cq9B3WmwWU+iy--
