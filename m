From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] [patch net] e1000: fix vlan processing regression
Date: Tue, 20 Mar 2012 03:03:17 -0700
Message-ID: <1332237797.2906.58.camel@jtkirshe-mobl>
References: <1332237473-11311-1-git-send-email-jpirko@redhat.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-T9C2EYXlwjQm9pi2NPmN"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:53928 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758784Ab2CTKDS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2012 06:03:18 -0400
In-Reply-To: <1332237473-11311-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-T9C2EYXlwjQm9pi2NPmN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-03-20 at 10:57 +0100, Jiri Pirko wrote:
> This patch fixes a regression introduced by commit "e1000: do vlan
> cleanup (799d531)".
>=20
> Apparently some e1000 chips (not mine) are sensitive about the order
> of
> setting vlan filter and vlan stripping/inserting functionality. So
> this
> patch changes the order so it's the same as before vlan cleanup.
>=20
> Reported-by: Ben Greear <greearb@candelatech.com>
> Tested-by: Ben Greear <greearb@candelatech.com>
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c |   35
> +++++++++++++++---------
>  1 files changed, 22 insertions(+), 13 deletions(-)=20

Thanks Jiri and Ben! I will add this to my queue.

--=-T9C2EYXlwjQm9pi2NPmN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPaFXlAAoJEOVv75VaS+3OKGYQAJysiLjNV568CEXbqlyL5zB2
M8ErkPPWPz42TETTINiMwMoQOFPvRra3pDUCWYXiAlzhi5LnBJyjbOPz8hnYWLrN
MShi5R2giP6/0j77tUIpnz/d0OEdany9zPsy+mSYMAbMi8x0JdLocGlWAlHUahE8
LdkxQ++VmaQvzUdg5P6VMNHqvsDhcQOghkBN3f9fwd5zwk+/3fmGCL0t6Qb48r6m
cHgKhQKdRvvWekol1Xdl8LwnU0GGSPltvkTrF+TEwudZj1msXobCpYNwN5GKQtQ4
FrFXWDXYnUtX3+cgJzMfrEppTawOoyyHoT4pltwFVDBJY9AlXx00Zfow6f2egJkE
DwwfVBxmsYAPrioHZzXYn1W0+KYhlJgYEBbtJRhF2XmjJsI7xGMYp6so+PS9eN2N
GWS+ZGTESB63vMtrVHekSrCksbtTfF+xRuZw+uEoKMVVJ7E52uG/sr/MSVR1SLuU
jo6dMY6y6stjM2xEkGMxJTGc9N29fxJmJa+WaYwXEEZNIi6JBKtj63HGYSAOBfza
n17GXgi+YwdgybLZzh8UxKQ/HwChLpAMDbXwXIOZrVo8pPLjA3S2+JTDv3aKw+1o
zUDkcTHrph7+8HAd76ygtlYn18wUTLnAm1DQ7no/L1q8LcwXa064xSpD7mbNC6NV
C4FPGgrkvsMI047Vksgs
=F+AV
-----END PGP SIGNATURE-----

--=-T9C2EYXlwjQm9pi2NPmN--
