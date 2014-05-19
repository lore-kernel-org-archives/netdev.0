From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Mon, 19 May 2014 13:38:28 +1000
Message-ID: <20140519133828.0ee2992b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/ByXZn7gcZulq9kSNygyJuXt"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?UTF-8?B?QmrDuHJu?= Mork <bjorn@mork.no>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/ByXZn7gcZulq9kSNygyJuXt
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (arm
multi_v7_defconfig, gcc 4.6.3) failed like this:

drivers/built-in.o: In function `cdc_ncm_get_coalesce':
ak8975.c:(.text+0x1ac994): undefined reference to `__aeabi_uldivmod'

(The file name above seems to be rubbish, the above function is in
drivers/net/usb/cdc_ncm.c)

Probably caused by commit 6c4e548ff366 ("net: cdc_ncm: use ethtool to
tune coalescing settings").  I assume that there are some 64 bit
divides in that function.

I have used the net-next tree from next-20140516 for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/ByXZn7gcZulq9kSNygyJuXt
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTeXy5AAoJEMDTa8Ir7ZwVrAEP/1Dz8DE4XmPD5bCWS/3Rs3Cn
oIKgMh87rI+ibwqz4e1HYBUypFZbd9+qO11KqwqsxdolW72HjWy9DKSx92uN+DtI
znvW0wSgiWZeDuOjEGxjCY0dxZ01S6I2ReO7r7T9dH6jivb/1rQSPVR8NCinex8b
pCO1kvsk/dj3JT27xUQe16wrUPSBh72+BW6S58VGCP8V/169QUxf9w1LeF47lgbI
oYdKYK2icK+HwpBsGFHkClwE0dmpzY8CVNHr3nyeHQRYe0RCHK+ZPO+x8LMeHT3u
qc+9MqYWxQXuwUa46iCJ2n7dTXaI7jzM3hMTkG4+V2wn92fD5K38qIwSqZ5dX0Nb
RfDW0tN+UpUQSEVB7i5NunNB6PHezrD1GdCl0krJmgNPUq2XOE6BRpeaN1gWfKV1
LznibdU80bzd3lLQr7H+zsQIUvwhvI/WrUQxjA0vmMlepGeHCMgPcH97opy7NkQw
B5SXEsLRFaTKDIIypb6mXRc8to6BiwndJpoddJ5SxTAulfc4NqeiiK6zVHPs/z3U
30WMfvhM9ED+QSeZhks9/jfku8/SXcPwJUhPW8FzLCMijuNeaNCbp4VEwtlQo8XO
aBQQBggJ9S4YOu/Xwhjs02nvDbVL1ZmwJTOoD7thj41tqqJia4Yuaouvg8eJ2xVN
sha1izeViRyy99ZSoQVk
=Zzfd
-----END PGP SIGNATURE-----

--Sig_/ByXZn7gcZulq9kSNygyJuXt--
