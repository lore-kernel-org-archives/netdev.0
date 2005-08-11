From: Harald Welte <laforge@gnumonks.org>
Subject: [PATCH 2/2] fix NF_QUEUE_NR() macro
Date: Thu, 11 Aug 2005 09:13:21 +0200
Message-ID: <20050811071320.GB4137@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jCrbxBqMcLqd4mOl"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--jCrbxBqMcLqd4mOl
Content-Type: multipart/mixed; boundary="kfjH4zxOES6UT95V"
Content-Disposition: inline


--kfjH4zxOES6UT95V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave, please apply!

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--kfjH4zxOES6UT95V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="44-nf_queue_nr.patch"
Content-Transfer-Encoding: quoted-printable

[NETFILTER] Fix NF_QUEUE_NR() macro

I obviously wanted to use bitwise-or, not logical or.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 359a4ba102b661dbd8da28b9dcb3330656a7a963
tree 3d1549cbff8af472bf761322b468ccd0d5be55c2
parent 5d6a0527049e43780fdaef065d0240a3338f92fd
author Harald Welte <laforge@netfilter.org> Di, 09 Aug 2005 09:32:02 +0200
committer Harald Welte <laforge@netfilter.org> Di, 09 Aug 2005 09:32:02 +02=
00

 include/linux/netfilter.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -29,7 +29,7 @@
 #define NF_VERDICT_QMASK 0xffff0000
 #define NF_VERDICT_QBITS 16
=20
-#define NF_QUEUE_NR(x) ((x << NF_VERDICT_QBITS) & NF_VERDICT_QMASK || NF_Q=
UEUE)
+#define NF_QUEUE_NR(x) ((x << NF_VERDICT_QBITS) & NF_VERDICT_QMASK | NF_QU=
EUE)
=20
 /* only for userspace compatibility */
 #ifndef __KERNEL__

--kfjH4zxOES6UT95V--

--jCrbxBqMcLqd4mOl
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC+vqQXaXGVTD0i/8RAm4qAJ4xfs+AKeEtw7WR5dmpbLg7o2V5aACdHBe7
EIEXYzm6bs5g6lMT3r7j+gc=
=KK96
-----END PGP SIGNATURE-----

--jCrbxBqMcLqd4mOl--
