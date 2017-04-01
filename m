From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 0/4] ixgbe: enable Relaxed Order for ARM64
Date: Sat, 01 Apr 2017 01:39:22 -0700
Message-ID: <1491035962.3211.3.camel@intel.com>
References: <1491031554-19516-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-2NfZ+hEWiuhbSnBt9PZE"
To: Ding Tianhong <dingtianhong@huawei.com>, catalin.marinas@arm.com,
        will.deacon@arm.com, mark.rutland@arm.com, robin.murphy@arm.com,
        davem@davemloft.net, alexander.duyck@gmail.com,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57288 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750849AbdDAIjc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 1 Apr 2017 04:39:32 -0400
In-Reply-To: <1491031554-19516-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2NfZ+hEWiuhbSnBt9PZE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2017-04-01 at 15:25 +0800, Ding Tianhong wrote:
> The IXGBE_ALLOW_RELAXED_ORDER will enable Relaxed Ordering (RO) which
> allows
> transactions that do not have any order of completion requirements to
> complete more efficiently compare to the Stricted Ordering (SO) for
> ixbge
> nic card. Some architecture will see high write-to-memory performance
> when RO is
> enabled on the data transactions just like the SPARC did.
>=20
> The aarch64 could both support Relaxed Ordering (RO) and Stricted
> Ordering (SO),
> so enable this config could get much more better performance, didn't
> see any
> adverse effects.
>=20
> The ARCH_WANT_RELAX_ORDER looks more general and would cause
> misleading and
> ambiguous, and till now only ixgbe could enable this "flag", so
> rename this
> config more specific.
>=20
> After discussion with the architecture maintainer, enable this config
> in driver
> looks more appropriate to compatible several architecture just like
> SPARC and ARM64,
> maybe we need more discussion about this, so let's begin by this
> patch set.
>=20
> In the last patch 1a8b6d76(net:add one common config ...), Mao only
> fix the
> config name issue for 82599 pf, but the 82598 and 82599 vf still need
> to be fixed,
> so rename the config all in the drivers to instead of CONFIG_SPARC.

Thank you for at least CC'ing me, but please remember to also CC intel-
wired-lan@lists.osuosl.org mailing list.  It make it easier for me to
add your patches to my queue and makes it visible for the
developers/validation people who will be reviewing and testing your
changes.

>=20
> Ding Tianhong (4):
> =C2=A0 ixgbe: sparc: rename the ARCH_WANT_RELAX_ORDER to
> =C2=A0=C2=A0=C2=A0 IXGBE_ALLOW_RELAXED_ORDER
> =C2=A0 ixgbe: ixgbevf: Clear the CONFIG_SPARC for ixgbevf and 82598
> =C2=A0 ixgbe: move IXGBE_ALLOW_RELAXED_ORDER from architecture to driver
> =C2=A0 ixgbe: enable IXGBE_ALLOW_RELAXED_ORDER for ARM64
>=20
> =C2=A0arch/Kconfig=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 | 3 ---
> =C2=A0arch/sparc/Kconfig=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 | 1 -
> =C2=A0drivers/net/ethernet/intel/Kconfig=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 | 4 ++++
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c=C2=A0=C2=A0=C2=A0 | =
4 ++--
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_common.c=C2=A0=C2=A0 | 2 +-
> =C2=A0drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 2 +-
> =C2=A06 files changed, 8 insertions(+), 8 deletions(-)

--=-2NfZ+hEWiuhbSnBt9PZE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAljfZzoACgkQ5W/vlVpL
7c55GA/8DdAifwMocbq+TEJZJbg/bC/Ek0yxSHbC/6hth4gh/Od1s2KmaOw97tpt
HKR4XXHOhM/GMhgBt6LKFiaXBRqYfaZ8Ug9WR6vzN+3uhXG9W3z07sLA9cRGuRsh
2XP1KrOhusEdhpouzVs+18FlnZNpEugoDNKsy9nL4bU6f8ou+2rke8u0DXBXKWnG
njBtCdvp9vQNb3curulO4exgLt9zf8lFg7kBuSxW7jtbirWZfV+G0N66EWprFqvB
HCA+VlF5IC9oX6lXYDApIuOkP7/wAHKwzCUz3DC9vQIpFsLbWq9TAwmTJ1SLBlNY
SBD6xBkEjTg5qjAk3/HOAqSc8K5SJLtxRqb+BfNED6+EIStHCKJt/ESoaGGdsZ1c
cLls7IzdSorFtHfMC2opprMsEkMBTOTyxR/ioxTU/XXjIxyjED8KTL7J0BW418mr
t+0kKYFyzl5StnuEwI4fYqttWq9WvIUnnmpyFzQkvd8pSjdPYloAhUT0e2TaNkv6
1DrYrOUW+a//z9iZhv9odEcsuE4maWGdze3Nwwu+sNsCvCmRFARbGvjVTrbiQeRO
vgn7+p9KZrriFht5/z/sVJ4+vRHo/Q0bCDjR8oAHtyFRX81rTtTMJHXsKXgJuGV/
s1I+E73fUr3Kg3QcJhbV0KszJt4pIRPYiDNFFZ2XCAXZJZQ2f64=
=MUTa
-----END PGP SIGNATURE-----

--=-2NfZ+hEWiuhbSnBt9PZE--
