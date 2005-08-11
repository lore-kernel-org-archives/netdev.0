From: Harald Welte <laforge@gnumonks.org>
Subject: [PATCH 1/2] make nf_log compile with PROC_FS == n
Date: Thu, 11 Aug 2005 09:12:43 +0200
Message-ID: <20050811071243.GA4137@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MfFXiAuoTsnnDAfZ"
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


--MfFXiAuoTsnnDAfZ
Content-Type: multipart/mixed; boundary="W/nzBZO5zC0uMSeA"
Content-Disposition: inline


--W/nzBZO5zC0uMSeA
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

--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="42-nflog_no_procfs.patch"
Content-Transfer-Encoding: quoted-printable

[NETFILTER] Fix compilation when no PROC_FS enabled

Signed-off-by: Harald Welte <laforge@netfilter.org>

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -166,12 +166,12 @@ int __init netfilter_log_init(void)
 {
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *pde;
+
 	pde =3D create_proc_entry("nf_log", S_IRUGO, proc_net_netfilter);
-#endif
 	if (!pde)
 		return -1;
=20
 	pde->proc_fops =3D &nflog_file_ops;
-
+#endif
 	return 0;
 }

--W/nzBZO5zC0uMSeA--

--MfFXiAuoTsnnDAfZ
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC+vpqXaXGVTD0i/8RAllEAJ4/VX26AA9DpD6LLN/aEVPpeu9ArgCgqsn0
OzC7jTN6fwmdDTQ8mryEaik=
=HJHK
-----END PGP SIGNATURE-----

--MfFXiAuoTsnnDAfZ--
