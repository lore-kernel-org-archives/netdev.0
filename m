From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm tree with the net-next tree
Date: Wed, 6 Nov 2013 20:00:19 +1100
Message-ID: <20131106200019.4dae95f0346ec60f8415da96@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__6_Nov_2013_20_00_19_+1100_v.NQNBUTrKj4wyMw"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__6_Nov_2013_20_00_19_+1100_v.NQNBUTrKj4wyMw
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

Today's linux-next merge of the akpm tree got a conflict in
net/netfilter/ipset/ip_set_hash_netportnet.c between commit 1a869205c75c
("netfilter: ipset: The unnamed union initialization may lead to
compilation error") from the net-next tree and commit
"net/netfilter/ipset/ip_set_hash_netportnet.c: fix build with older gccs"
from the akpm tree.

The latter is just a subset of the former, so I dropped the latter.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__6_Nov_2013_20_00_19_+1100_v.NQNBUTrKj4wyMw
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSegUqAAoJEMDTa8Ir7ZwVgSYP/06Z0G9A/EZ3FKgYTw5FMH3n
tvaxDJCcPwL/GE3GLM6r8HIuv4ZhXtPGwH5atUwIfNlIsgHdFaZB8Fr3hktv+6EN
J1iyI/FfRzkEUcv1qbGLYTYJEESZDxy0yP+yLlF0YIcepq2yMgNpZln9bfL3ihG5
Ur3p04tuFU0fT6GJrb1SOF39bIOgZn1EWqtuivZiZHbBM/SBD0dRF63H+BAUoBjJ
lnWI433XnZf0KePBZ54GCQBS3mx0+U6BSlIUT+mclnzJY+AGn/eeIJ/jq6ng1LfE
xsYWcggvtlzo84UEyOhip9BBCRpa00VYi6QUsNfYTo4Ie3lQavxMlFFC8snonsgg
cGTe0mN0LFHCfdwWdHoYAUGatHTHPdGqFv2O6gBAhmomvx18bTpPBUPrtkgB6sRe
gJ4RvvnrFydsa785s8XtTvKzxjjQ3Qj6KGx9zq/Is2tH8b37QcRzOgI5fqlhoP6D
/ZOpljKEAIhiJV2VW/tj+8MFNNnz0AEoqSJ1E3ftFtZVKXBODMpOtJaH8leiqVMl
irOKvDLPG66dJEQC1uer6jiYch93aC78DshZi/Gvkq01rUH3RwMpnmbIH6Qlk5n3
SdnnEnQFHR3I3m5uiFI6zlwkWICOrkXmEY43RiaeKYtpQa8LGKa+wFmwl4EjLdpQ
17hMvfHseLBYgvsScrJT
=hwUD
-----END PGP SIGNATURE-----

--Signature=_Wed__6_Nov_2013_20_00_19_+1100_v.NQNBUTrKj4wyMw--
