From: Harald Welte <laforge@gnumonks.org>
Subject: [PATCH] fix nf_info_reroute() macro
Date: Wed, 27 Jul 2005 00:01:15 +0200
Message-ID: <20050726220115.GC4673@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="yQbNiKLmgenwUfTN"
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


--yQbNiKLmgenwUfTN
Content-Type: multipart/mixed; boundary="yH1ZJFh+qWm+VodA"
Content-Disposition: inline


--yH1ZJFh+qWm+VodA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

This patch fixes the pointer calculation made by the nf_info_reroute() macr=
o.

Please apply on top of my other patches for net-2.6.14, thanks.

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--yH1ZJFh+qWm+VodA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="15-nf_info_reroute-fix.patch"
Content-Transfer-Encoding: quoted-printable

Fix calculation of structure end by nf_info_reroute()

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 08fcbede51cf315a0e7aa9b2d6bbdd0aad05cd54
tree 3c7ea5a64f856f2acff65a0b3bd2c40dfac5cf77
parent 7237f235b6bd25773b566d88ec846245c852b1ee
author laforge <laforge@netfilter.org> Di, 26 Jul 2005 23:53:58 +0200
committer laforge <laforge@netfilter.org> Di, 26 Jul 2005 23:53:58 +0200

 include/linux/netfilter.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -216,7 +216,7 @@ struct nf_queue_rerouter {
 	int rer_size;
 };
=20
-#define nf_info_reroute(x) ((void *)x + sizeof(typeof(x)))
+#define nf_info_reroute(x) ((void *)x + sizeof(struct nf_info))
=20
 extern int nf_register_queue_rerouter(int pf, struct nf_queue_rerouter *re=
r);
 extern int nf_unregister_queue_rerouter(int pf);

--yH1ZJFh+qWm+VodA--

--yQbNiKLmgenwUfTN
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC5rKrXaXGVTD0i/8RAj+rAKCQEQ4F5CGAGKj0D/EeIo2J2rkH8gCfc124
ztLs/F8YHOInRsBs8PlzHP4=
=s1H/
-----END PGP SIGNATURE-----

--yQbNiKLmgenwUfTN--
