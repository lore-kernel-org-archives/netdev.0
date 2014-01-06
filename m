From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the net-next tree
Date: Mon, 6 Jan 2014 15:53:34 +1100
Message-ID: <20140106155334.7e449a674943bc43890f4a08@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__6_Jan_2014_15_53_34_+1100_XK_4A7FJNY.t17HM"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	dingtianhong <dingtianhong@huawei.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__6_Jan_2014_15_53_34_+1100_XK_4A7FJNY.t17HM
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (x86_64
allmodconfig) produced this warning:

drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c: In function 'qlcnic_send_fi=
lter':
drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c:349:3: warning: passing argu=
ment 2 of 'ether_addr_equal' from incompatible pointer type [enabled by def=
ault]
   if (ether_addr_equal(tmp_fil->faddr, &src_addr) &&
   ^
In file included from include/linux/if_vlan.h:16:0,
                 from drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c:9:
include/linux/etherdevice.h:244:20: note: expected 'const u8 *' but argumen=
t is of type 'u64 *'
 static inline bool ether_addr_equal(const u8 *addr1, const u8 *addr2)
                    ^

Introduced by commit 6878f79a8b71 ("net: qlcnic: slight optimization of
addr compare").

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__6_Jan_2014_15_53_34_+1100_XK_4A7FJNY.t17HM
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSyjbSAAoJEMDTa8Ir7ZwVUvsP/3MbRJq/r/3wu8NVaR6nM3rt
zXtAwYQf619AY+EeDQLFdn8FMq6JsBvOKPizsFw71D7w3Wn7EZBhoDEUmCvc2c0f
GMcGRYmAaOeHPeVnb+FLPPgDCpd/9Ym6ndrZCEDTv3YVKtqLRop+fLFeBL/gzycA
7NFLN8DuP32qVbiDOEdMeQeuM72AjFWIx1F932hswpFLP/JiHodwoyd42dW7iYN1
u1ZhaagmB0/lGi+SpoBXP+SqW2cW50wDdcmmObTy0BoQBcNwes14yHRpe4IwF2kM
I6LqKlYfgsRqYuPtNNndD8SuMU5E+JM6ByA94xXS7RNhENGz2gxak9SUMB0mHnWI
L5HNtUmVNf5MxxtEP2tvz2i+YIrH35s2gCXr7GuNtz4hecxjySarRY4s4Czh0yNR
xhYJlWRN124v8WhFZWOJi3V/UfoOpjBtG3svrNuV1mPmCOLAjXbagd5Vq7VvLjzt
GtgWNVaa+5V/dzBDfA8j8BVSv73/CJb9JMX2j/JunFf7Ez6wDci3CVYgnTUILThV
0bqpp58r0wdhPid6AP0QJ2+GjTJSAqrWcvphlFZscG7Cqwj7+CW1W1mMik4pLWIc
2lnd6CPRmH+o8uQaZgcs7iza6x7kJNGBy0CtrBl/HZiokPRYrEXRHjJPpkwtVY4u
/BXQkF0p3CsXOT+h6gq5
=sl1l
-----END PGP SIGNATURE-----

--Signature=_Mon__6_Jan_2014_15_53_34_+1100_XK_4A7FJNY.t17HM--
