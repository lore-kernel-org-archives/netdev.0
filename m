From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Tue, 10 Feb 2015 22:02:15 +1100
Message-ID: <20150210220215.5f87a13c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/he6iGAd=Jm3NY/WRbY_ZUrY"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/he6iGAd=Jm3NY/WRbY_ZUrY
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (i386
allmodconfig and a few others) failed like this:

drivers/net/ethernet/intel/i40e/i40e_txrx.c: In function 'i40e_setup_rx_des=
criptors':
drivers/net/ethernet/intel/i40e/i40e_txrx.c:1101:3: error: incompatible typ=
e for argument 1 of '__seqcount_init'
include/linux/seqlock.h:53:20: note: expected 'struct seqcount_t *' but arg=
ument is of type 'seqcount_t'

Caused by commit 638702bd59a3 ("i40e/i40evf: Add call to u64_stats_init
to init").

Discovered after the release, so no fix done.

The indentation of the lines added by that patch is also a bit strange.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/he6iGAd=Jm3NY/WRbY_ZUrY
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJU2eU9AAoJEMDTa8Ir7ZwVpXkQAJXyr211iM4kkzyyCpOGhfPk
x8dKxQ0g8Tmiiqozzov4dP4eHQDXRz+lsB74VGAPv0dxatwunbCZ8DE+PagIxQ8j
h6MbmoAobFlScK3HpPkmEQ2b2CwBAYO0v3PTyytBmm/eV6ojyWClcQBiR8eJTq2m
1hhRKyhk1y3Cg4tT3xgnDkkTeEryHg3FxPC3b/zHej7Vm2Jm+WlmegxmfphgrCcZ
kKI8EyJvxFBl9a8BIb17+gKGlIRVfFTChKUYn36MBpsXXwVxxzg6WoLcOwr4G6jy
CN9Rvn9UAxAxDpT2Ew8TtZ6Pc3qMs0ML983V9DgpYyBWl7/mqBsLk3fmJROhv8hu
+yk7/PToVBhYsouXyi1NZwsJGMWrCfPPXgnlfr0y72mrf0tvneHKAr9w/disoUvn
Ep60MY/V3TfFAkbrsy7QMYU1it3maVB+39pPK/VGibij2cRySmqSMlpuUFnaEAYa
Umu4OH85kZ2zkOJu1geVlp168xvmWQksrdnejidyXBgnCewlKNdggqS9KqcUHOoX
2sdEWJaH8ugpH63NfTr0NY9wSTaf9Fu2liIp+9YYwJgEcRyCDWDe7E/US0WLer36
CabKUb64yaVS7oeSBjI5Lxdx/vx2+jJGGSj9ZEi2YHfRaFnHq//1aLW3oX4Fnppz
9RT+Imwdh4ZG25wVldtj
=RAat
-----END PGP SIGNATURE-----

--Sig_/he6iGAd=Jm3NY/WRbY_ZUrY--
