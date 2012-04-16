From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the security tree with the net-next
 tree
Date: Mon, 16 Apr 2012 13:29:04 +1000
Message-ID: <20120416132904.85e0f40b3e509f42c3f3284c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__16_Apr_2012_13_29_04_+1000_+opk4LkRiaad2SzE"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Jiri Pirko <jpirko@redhat.com>, Will Drewry <wad@chromium.org>
To: James Morris <jmorris@namei.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__16_Apr_2012_13_29_04_+1000_+opk4LkRiaad2SzE
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi James,

Today's linux-next merge of the security tree got a conflict in
include/linux/filter.h between commit ffe06c17afbb ("filter: add XOR
operation") from the net-next tree and commit 46b325c7eb01
("sk_run_filter: add BPF_S_ANC_SECCOMP_LD_W") from the security tree.

Just context changes.  I fixed it up (see below) and can carry the fax as
necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc include/linux/filter.h
index 7209099,f2e5315..0000000
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@@ -232,7 -239,7 +243,8 @@@ enum=20
  	BPF_S_ANC_HATYPE,
  	BPF_S_ANC_RXHASH,
  	BPF_S_ANC_CPU,
 +	BPF_S_ANC_ALU_XOR_X,
+ 	BPF_S_ANC_SECCOMP_LD_W,
  };
 =20
  #endif /* __KERNEL__ */

--Signature=_Mon__16_Apr_2012_13_29_04_+1000_+opk4LkRiaad2SzE
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPi5IAAAoJEECxmPOUX5FEIIIQAJEPizRReIZYjMGafUwd+GWa
7r6RNyNhYoM0+D7nl2DybWupqVzOkkNoTtLR545hXa8iHg7crKiY0lhIGA2DtxYQ
rnZ3ZdGT8AAJTHh8MT9t9cGl7r3g7yJDV2RPmetW0bAjBpTGaG/hacpZ9TRi1PFq
XMphsmvkLKGYb2SMy7frvp8Lh3NO+hMMdmeQfuBzLx13belYjiK/J1kccJAPet74
PWE/zWgZGzQAq3doX/3dJqVNQ9P8E9xh9b7b0jOPchRYW0oxGoy041RZcvndKXxG
37OKycxnlgERt+OUJpoksJu7K9azKOPDrMkNv3wrPY1C4t6aiXjmjNKjfM9U2DOY
yIOq+AxJ30JAXEhn73Y2QtZ6AscVzKO81EdAUH3vkM4qMJCeHsLNpFy7bv2kJ12z
JbImIjqOKVqL6KCIQO16BrzmKFSe//tmzvsum4r7+GwsNYhT7n9wdH5RCAlyUhjn
ypkYR095CxOv4JvmmKX4pVXAXxykmKgs+aG+SbeyRZCg1ph5+Zyq51fpOIB3Py72
o8+CE0cfLlv4oGK7Aq1v6xylgYThoVffOiHcCHdcL94UmQxUPuecfnooHNduUX7P
+VofWDQ+d9xF1BTArlM3m0X8AptxzdlVkDCXTnnrswLiFShvmktmcBI3+P83QOqY
RYr0cnJy2DkIHpydkfoo
=gK7b
-----END PGP SIGNATURE-----

--Signature=_Mon__16_Apr_2012_13_29_04_+1000_+opk4LkRiaad2SzE--
