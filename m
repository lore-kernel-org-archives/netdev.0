From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the final tree (net tree
 related)
Date: Tue, 4 Jun 2013 17:27:00 +1000
Message-ID: <20130604172700.a98a93d8743f32153d0c93f2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__4_Jun_2013_17_27_00_+1000_cLGzmPIL_NgkMxNN"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Lorenzo Colitti <lorenzo@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__4_Jun_2013_17_27_00_+1000_cLGzmPIL_NgkMxNN
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (i386_defconfig,
sparc64_defconfig) produced this warning:

net/ipv6/ping.c: In function 'pingv6_init':
net/ipv6/ping.c:87:27: warning: assignment from incompatible pointer type [=
enabled by default]

Probably caused by commit 2a7851bffb00 ("netfilter: add nf_ipv6_ops hook
to fix xt_addrtype with IPv6") interacting with commit 6d0bfe226116
("net: ipv6: Add IPv6 support to the ping socket") from the net-next tree.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__4_Jun_2013_17_27_00_+1000_cLGzmPIL_NgkMxNN
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRrZbIAAoJEECxmPOUX5FE2fIP/2UXQqsck/r3Q46+AL+AXZ9N
ABLCB7PLFEAtjYCZQq43YA4R0NBKXJe6ECNfN1mLETnvH9OBSdl7WeNKq1TRgQa6
WiQFcgoJoLYdmrAuB6xy9iwnRSGupeyknRQo3q7S+FZ2NxjWkeulqlNU2Q/M0bIU
w+c9ZQtItiIPpAYwNkEFGHG70ruqtL0mNYDWPlvmfhMIXwPbKWVRfIPJDmou93dq
rWDBm0a9kLgF1U1TPALTUaZ8t6C3EMsNJ3/Mzz40NC4Hj0Lx4VKC9Mjeki00yZ3q
mmjMGy188ONvPEyspHeXKjSwyLaJ6mzIhXWGLdLiJFdAeP/Fv+xNqk01uxC5Ik0n
/kxm2nQtT7E6AinhcVUYSePrgecxYTzR5zY47Xe5ovaoISvLMCrRmGz1sLEQLfUD
+ymybwczP0xDfAD5NT51gjt4LJ21k9lF04PYCccBXNfS/iWHSiP5YbmAPwroRXsY
eglpy10vMftQjScoQnvpMJmDeW5VwQFHZTpIfeWQiLvpPVRXidRPvQ7h0rPat1/Y
a0tMVW92ErOIDr8Vn0DZ50fXX3htUMWppzN5S+EQqW3PsHULX6t9kirBiNyFLf0l
isR6UKJuZgvUwRTm1jafuOQrAr9wv8KGI+TSFRJzijz59mk/JGdmZMwJGVQNOjz8
GbvPZQMgmdoyNDIOLf53
=PEn0
-----END PGP SIGNATURE-----

--Signature=_Tue__4_Jun_2013_17_27_00_+1000_cLGzmPIL_NgkMxNN--
