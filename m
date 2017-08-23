From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC PATCH v2 3/6] [net-next]net: i40e: Extend set switch
 config command to accept cloud filter mode
Date: Wed, 23 Aug 2017 03:43:27 -0700
Message-ID: <1503485007.43048.31.camel@intel.com>
References: <150296538797.16910.13738130623106637990.stgit@anamdev.jf.intel.com>
         <150296562149.16910.5659916522674039966.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-S+zjix73AbxtuM5FOTRD"
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        netdev@vger.kernel.org, mitch.a.williams@intel.com,
        alexander.duyck@gmail.com, neerav.parikh@intel.com,
        sridhar.samudrala@intel.com, carolyn.wyborny@intel.com
To: Amritha Nambiar <amritha.nambiar@intel.com>,
        intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:61758 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753789AbdHWKnf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 06:43:35 -0400
In-Reply-To: <150296562149.16910.5659916522674039966.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-S+zjix73AbxtuM5FOTRD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2017-08-17 at 03:27 -0700, Amritha Nambiar wrote:
> Add definitions for L4 filters and switch modes based on cloud
> filters
> modes and extend the set switch config command to include the
> additional cloud filter mode.
>=20
> Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
> Signed-off-by: Kiran Patil <kiran.patil@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h |   31
> ++++++++++++++++++++-
>  drivers/net/ethernet/intel/i40e/i40e_common.c     |    4 ++-
>  drivers/net/ethernet/intel/i40e/i40e_ethtool.c    |    2 +
>  drivers/net/ethernet/intel/i40e/i40e_main.c       |    2 +
>  drivers/net/ethernet/intel/i40e/i40e_prototype.h  |    2 +
>  drivers/net/ethernet/intel/i40e/i40e_type.h       |    9 ++++++
>  6 files changed, 45 insertions(+), 5 deletions(-)

Unfortunately, this does not apply (not even close).  Since you are
needing to make changes to the first set of 6 patches, please rebase
your entire set of patches to my latest tree and that should fix the
issue.
--=-S+zjix73AbxtuM5FOTRD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAlmdXE8ACgkQ5W/vlVpL
7c7VBA//WugiVkqxoMsLaH0TJMt8LDTZAsb249BA16wLWQ24V9cvH5JfO5zoXOjf
ddkoQ7uh+XSBBcexJQlLEPxK2OQTcr/FDTqS//OC84PoQb0cu9oJ08kEXl0KpFZW
yTCVKCHnoNPBEmN0Wr8IIqD4o/UMgJunnnl5M6bUDvXOGlepbJbxFzCYJQOi55lb
APysw6hEem1n27vLhH5trF14J+v6CzAzwfq9WmUrybkOavegCtRgyQFJLu8pfhjP
1C+WRk3up/6kt+nsXHfI5fqMXVPB3KhgiUDKprSVRIZvOUJq95Kmmhf3QHYfa+99
KhgRvXCAg/DX2bL46sYon4XNX+vD+jDw7yPVxI3/ZC4PbVtdE2NLAJEFhsBdLLyK
G+f5SVeuEJjhUk/HUhghCJx3/dgr+8wcSqZWcn0crlWpUTcZGsILnYhmIkcYivTr
UerQCi68As/gMd/Qax61L77fPo9Yy+qSj3w7HLkuv/0Dhrh45FweEfqF8S+8LARM
vtnZ3luu9lhg/7gIaN8qx0cfHQy+F/ftg4PgiRA795QN5hlFv+tAnv60R91ZzU6k
f9vUZEKY1LHBhQpKjcby5WTxtfHI35pYmtmcqiEcPWS2Lyx2b2N91JH0ykxJ3OWI
9Bv7xvKyNQ2hOX21eXtd0dDzNXOW/J88E1aKA0Y6Jhln9/MBEqE=
=nX6d
-----END PGP SIGNATURE-----

--=-S+zjix73AbxtuM5FOTRD--
