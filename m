From: Harald Welte <laforge@gnumonks.org>
Subject: [PATCH] add autoloading support to nfnetlink_log
Date: Mon, 8 Aug 2005 00:15:35 +0200
Message-ID: <20050807221535.GC4508@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VIOdPewhitSMo36n"
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


--VIOdPewhitSMo36n
Content-Type: multipart/mixed; boundary="7SrMUQONj8Rl9QNG"
Content-Disposition: inline


--7SrMUQONj8Rl9QNG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Please apply, thanks

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--7SrMUQONj8Rl9QNG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="33-nfnetlink_log-autoload.patch"
Content-Transfer-Encoding: quoted-printable

[NETFILTER] fix autoloading of nfnetlink_log

This patch adds the MODULE_ALIAS required for netnlink autoloading of
nfnetlink_log.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 7e42bac6926c9ab54033ddc4695e9a3d30b6b453
tree aae33467661ea95482d218e22ceadfa448cc8a0d
parent c16fd4ffed6349d0888cd97a75d04394dac42021
author Harald Welte <laforge@netfilter.org> So, 07 Aug 2005 19:24:43 +0200
committer Harald Welte <laforge@netfilter.org> So, 07 Aug 2005 19:24:43 +02=
00

 net/netfilter/nfnetlink_log.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -1013,6 +1013,7 @@ static void __exit fini(void)
 MODULE_DESCRIPTION("netfilter userspace logging");
 MODULE_AUTHOR("Harald Welte <laforge@netfilter.org>");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_NFNL_SUBSYS(NFNL_SUBSYS_ULOG);
=20
 module_init(init);
 module_exit(fini);

--7SrMUQONj8Rl9QNG--

--VIOdPewhitSMo36n
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC9ogEXaXGVTD0i/8RAs2qAKCTTK3YsTlr49kfv+2c8lq2NuRD9gCgkil+
b3iujk95ZC0BKC8soxSoSiE=
=YhRg
-----END PGP SIGNATURE-----

--VIOdPewhitSMo36n--
