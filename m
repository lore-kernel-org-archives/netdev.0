From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the bluetooth tree with Linus' tree
Date: Fri, 1 Mar 2013 12:54:25 +1100
Message-ID: <20130301125425.1819c6cc77fb64be71351ade@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__1_Mar_2013_12_54_25_+1100_8Z82eTK66fLT_ln6"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ying Xue <ying.xue@windriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Dean Jenkins <Dean_Jenkins@mentor.com>
To: Gustavo Padovan <gustavo@padovan.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__1_Mar_2013_12_54_25_+1100_8Z82eTK66fLT_ln6
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Gustavo,

Today's linux-next merge of the bluetooth tree got a conflict in
net/bluetooth/rfcomm/core.c between commit 25cc4ae913a4 ("net: remove
redundant check for timer pending state before del_timer") from Linus' tree
and commit 5c87e6efd14d ("Bluetooth: Avoid rfcomm_session_timeout using
freed session") from the bluetooth tree.

I fixed it up (I just used the bluetooth tree version) and can carry the
fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__1_Mar_2013_12_54_25_+1100_8Z82eTK66fLT_ln6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRMApRAAoJEECxmPOUX5FEticP/jnWQCWky1nMBKuz70fEQC87
VIdFkpBiJ3XinwiEpFeVuFjdmEstj+92YjAWgPeqV1aSek2Ju0mUQievMPE3Ltn8
c1aNnfTGK/Q6PQjTTuAi0P45nmbTQhffXg4oiOa4UeNOZzKF/msq8Et9w//oHarK
fB3gg79bB88c9sH0g2YWS04vGUpggmFToaXXjer4caNIXti0qXOJL17ouloJ23qT
K3O1kDebDuJg9f8d/XbHTTrVgxyz9O/uMbblV9N/gqxLIsO/9mnV4PbZ3TjkcPRd
YS60ZqTOZENm4vxbxskmfSrMTxsE9Oz2Wl1XFtu/gv8dUUgAYzAAo+jCYIb6Vmy2
AoQzoAQY0sXDEqut36Hqrv2dNILD5Qb8YUj5/+Tc+ZsVVisGsnHsUgiEDR3/MTSM
EKex/WayY8D3dXVUGI8trK+7l03CHM8VmITx60p2tCF82NaJegwjZMzMRflrPfqX
byAmEbehR8xZ15ixvxSXdSHEHlFGsC7dEQVe77frAyeZgJD3N3DZgRFe0le7gGeo
juIOycH49dltamgfKdp/DVMFVDpGpX2/XariZkfwKCtTu/pZ/QFZ5Zzoj6nzkM2f
sxtFhekUSRyGNXpxrNxw+uBKnCG+DKqWQqpVAXoJ25K4tsHT8+u614Nh0tZvbsY0
o3shdbcVOPnuOPX59FuW
=TSIf
-----END PGP SIGNATURE-----

--Signature=_Fri__1_Mar_2013_12_54_25_+1100_8Z82eTK66fLT_ln6--
