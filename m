From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v10 4/7] ixgbevf: Add a RETA query code
Date: Tue, 31 Mar 2015 00:35:44 -0700
Message-ID: <1427787344.2497.112.camel@jtkirshe-mobl>
References: <1427740529-9605-1-git-send-email-vladz@cloudius-systems.com>
	 <1427740529-9605-5-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-4s392mAzIcrVGQWIk8HB"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37369 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753166AbbCaHfv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2015 03:35:51 -0400
In-Reply-To: <1427740529-9605-5-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4s392mAzIcrVGQWIk8HB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-03-30 at 21:35 +0300, Vlad Zolotarov wrote:
> We will currently support only 82599 and x540 deviced. Support for
> other devices
> will be added later.
>=20
>    - Added a new API version support.
>    - Added the query implementation in the ixgbevf.
>=20
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
> New in v10:
>    - Expose the _locked function in the vf.h interface according
>      to the current ixgbevf layering model.
>    - Return EOPNOTSUPP in cases then operation is not supported.
>    - Mask the received RETA according to the VF Rx queues
> configuration.
>    - Added IXGBEVF_82599_RETA_SIZE macro.
>=20
> New in v9:
>    - Reduce the support to 82599 and x540 devices only.
>    - Improvements in RETA query code:
>       - Implement a "compression" of VF's RETA contents: pass only 2
> bits
>         per-entry.
>       - RETA querying is done in a single mailbox operation thanks to
> compression.
>=20
> New in v8:
>    - Protect mailbox with a spinlock.
>=20
> New in v7:
>    - Add ixgbe_mbox_api_12 case in ixgbevf_set_num_queues().
>    - Properly expand HW RETA into the ethtool buffer.
>=20
> New in v6:
>    - Add a proper return code when an operation is blocked by PF.
>=20
> New in v3:
>    - Adjusted to the new interface IXGBE_VF_GET_RETA command.
>    - Added a proper support for x550 devices.
>=20
> New in v1 (compared to RFC):
>    - Use "if-else" statement instead of a "switch-case" for a single
> option case
>      (in ixgbevf_get_reta()).
> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  1 +
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  5 +-
>  drivers/net/ethernet/intel/ixgbevf/mbx.h          |  4 ++
>  drivers/net/ethernet/intel/ixgbevf/vf.c           | 70
> +++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbevf/vf.h           |  1 +
>  5 files changed, 80 insertions(+), 1 deletion(-)

Thanks Vlad, applied to my queue.
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-4s392mAzIcrVGQWIk8HB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVGk5QAAoJEOVv75VaS+3OAjYP/ijAhH4PuM3dMHcdKQ7iC1KC
nnFzTzyqMrHD95btlhFhzIvgyCL3EJHHaRQQNOoo8qkG9Iq99NXzeWeESWNFfIU+
S4/RbomZ86q5FXaLxvBYe2XdZ455blx/ntBpzdQjv5Iy6ACfAWxsyyvS/42o3Olu
VDh1tQbEmKYofQiS1BGMH4ZfgzuXn7QkL1oksYH4hzY5R0uJ4XAwsTEMJlyWtrbp
Wv1Na91WoEz87nQC58UbLua7/aKjHBbY89S9QhSFJyWVwBa8KEtBa391GFFZoBPj
pSK0SwXhtG9R5qYQIxNZsWNHP+2XRxa+ab5i6HsBVhFD2A3dbTc8QxbfQeFmutbJ
W0QNN5tT2fKp4RURU78zI5iptYtnZG5RGmU1S13gzzbyQmWxAkmDRCAv398sVPgV
40BktSPjGKi74QW+HRI/Zp1HAYThjrT8CCenCNI39HncJxtBYtYvlPxDmOyp/5nt
GB846dSFptpDe+GehvbIfvxH/RH44jknEMWK+QLsfx0LVlXSZNcN8Db+wN9+08JP
SwKEEBVj5IKF96pnqT3wsB8aK0IWSrzoiL4S8wMhxraO9Loe11KW8ib+gk5qCoGX
JROfeXOwDRLMElhJwNgyV5LY4I1pzcSujJRspXgbjp1bQQu/f2aD3Q55pKkyKKEE
Ek3d68ncbAdiD90M17L5
=arcZ
-----END PGP SIGNATURE-----

--=-4s392mAzIcrVGQWIk8HB--
