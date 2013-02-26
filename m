From: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Subject: linux-next: manual merge of the infiniband tree with Linus' tree
Date: Tue, 26 Feb 2013 11:45:08 +1100
Message-ID: <20130226114508.0f8d1101156f9f4a309579f6@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__26_Feb_2013_11_45_08_+1100_5VQ.Sey5M+0YYHMR"
Cc: linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Hadar Hen Zion <hadarh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shani Michaeli <shanim-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__26_Feb_2013_11_45_08_+1100_5VQ.Sey5M+0YYHMR
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the infiniband tree got a conflict in
drivers/net/ethernet/mellanox/mlx4/mlx4.h between commit 23537b732f5d
("net/mlx4_core: Use firmware driven flow steering hash mode") from
Linus' tree and commit e448834e3545 ("mlx4_core: Enable memory windows in
{INIT, QUERY}_HCA") from the infiniband tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org

diff --cc drivers/net/ethernet/mellanox/mlx4/mlx4.h
index ed4a695,8b75d5e..0000000
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@@ -60,6 -60,13 +60,8 @@@
  #define MLX4_FS_MGM_LOG_ENTRY_SIZE	7
  #define MLX4_FS_NUM_MCG			(1 << 17)
 =20
+ #define INIT_HCA_TPT_MW_ENABLE          (1 << 7)
+=20
 -enum {
 -	MLX4_FS_L2_HASH =3D 0,
 -	MLX4_FS_L2_L3_L4_HASH,
 -};
 -
  #define MLX4_NUM_UP		8
  #define MLX4_NUM_TC		8
  #define MLX4_RATELIMIT_UNITS 3 /* 100 Mbps */

--Signature=_Tue__26_Feb_2013_11_45_08_+1100_5VQ.Sey5M+0YYHMR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRLAWUAAoJEECxmPOUX5FEWXoP/ipAtcUnrZtBgk0zBNCOXBZs
PBEZbRhdyqLIVOwGkYDk53hyK4EzkvQw/3zpUXud85LEzl433sjFqLu1EVYowjzn
cYuXa8vYi8C3ehi/PImceRQttLjn5zIoFUoVTO54ks04m96+QQKnrfjBzRNIMcvV
ct6EpiqgaiQHFlxM9Wy1ai452uap2X2EYnGfOUAvStsxAry1FwmJKRb9lobWeDHD
GveG+n5oArmkDgntLN/fS//yXdkEihdWMBwyonmu7+RwMbRdqeiN4tDhsb/z35tF
b/68zE+eIrqbj8Ngcwpt77V5Ql3DlbiECO6e/jVyiWCcuW9t4D6fM1rS/et+ZhlF
iv/MHmPVBd2XWrH6EmCVpRQOvq6eeiEoIW8lnRuUHq5kJzzaycvs83PJHMPE4TGt
2sYmAB8G7vk9mEyqyjt/baPD4iDfk+Fl4ZAnlZ3SVACfV2RuUj3nrL12ZZXEumkr
JsodduCYAxv/kL4AWCeuSn3GdjuwOOICSvpAfxJOvTanr6JK/iODxNWH0ypnHnAB
ENMD1B3ctABIwilPPYyIEkZpUW4mh9vyubG9RwjllDK4UDyq2xrbh11WhtHL4Tmd
gg0ymFPsJul/KVtFqkYezkIcVPOjqofiojotHzbcXskcq7gjQdkpdNSrCDkzd7VC
iv0C5w77WdYfA7YZ3zVo
=YK2k
-----END PGP SIGNATURE-----

--Signature=_Tue__26_Feb_2013_11_45_08_+1100_5VQ.Sey5M+0YYHMR--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
