From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 27 Apr 2012 12:02:05 +1000
Message-ID: <20120427120205.3860dd924261ee7a7c42eda4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__27_Apr_2012_12_02_05_+1000_0+kj1ht.5khjefHK"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__27_Apr_2012_12_02_05_+1000_0+kj1ht.5khjefHK
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/intel/e1000e/param.c between commit 727c356f4d79
("e1000e: Fix default interrupt throttle rate not set in NIC HW") from
the net tree and commit 6ad651456e3c ("e1000e: cleanup remaining strings
split across multiple lines") from the net-next tree.

The former included the change from the latter, so I used that.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__27_Apr_2012_12_02_05_+1000_0+kj1ht.5khjefHK
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPmf4dAAoJEECxmPOUX5FEflkP/1jeHrlFOLJE21sat9zSfDmm
Olhc3cUQM5HXoAKhei2npS4IGU5IjPJ9rl10RBxhAGb8VxWin/Vc4JkbtMa6EhEi
toAEEgtx/WRzG7U76RkAf6dCs16ocXuok41NuVMrb6aTd1+hy4/UHjlWC32ql4Ah
y00cjG1/P0zXeUbQhJR1btr6UoKVoL7PJcuO77US8FFGOA2PqAUA6UfDuNw3SEGr
IXSexeEhvFayE4iITjXRtfxA+Ok7bb4Rmg8Z0QJbYlR+MpAprsQ+jP/eKXXeDm6H
rpQbMeho4bUdiXtU9QyeiJIALFChl7V7jNhDF+cAPlrgmq2MRX6XIlsOj846cxz6
/wxP+GWsJm6XxVdlVZ3wDcB4Es4Ylp7v4738SIo/51Vn2vnsRYIkctfdUYSUNQoe
C9WA2Kfc3wY8lxVDc14VL1iA0GOiTMs4xE9rsgQBv/+u46GUcgOhjoBFWJ/v7R4N
lgz4kdKvlUq5FoD2KKyOGyfNRlM9N3LW8W0f9lyb5ga/a+ZeqnduYHHhzeC8udrO
IUHYs4WBv/sfvlsgPZITyIHll9s9bHrHSMUnktrGGUnyLUg1yWK0kxzGGk/NhZrb
14TVEAK9C2z4hLew+aENEZRFV6bz334TlcgKoRWfYZl/TY2LhEX0nyap+RwVTSGe
sstA2PmlujhXIw7tO5ji
=PFYo
-----END PGP SIGNATURE-----

--Signature=_Fri__27_Apr_2012_12_02_05_+1000_0+kj1ht.5khjefHK--
