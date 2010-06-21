From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the tip tree with the net tree
Date: Mon, 21 Jun 2010 16:16:09 +1000
Message-ID: <20100621161609.935d0085.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__21_Jun_2010_16_16_09_+1000_NEGrOnCn9kXH9th6"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Jiri Pirko <jpirko@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__21_Jun_2010_16_16_09_+1000_NEGrOnCn9kXH9th6
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the tip tree got a conflict in
net/bridge/br_fdb.c net/bridge/netfilter/ebt_redirect.c
net/bridge/netfilter/ebt_ulog.c net/bridge/netfilter/ebtables.c
net/netfilter/nfnetlink_log.c between commit
f350a0a87374418635689471606454abc7beaa3a ("bridge: use rx_handler_data
pointer to store net_bridge_port pointer") from the net tree and commit
81bdf5bd7349bd4523538cbd7878f334bc2bfe14 ("net: Make accesses to
->br_port safe for sparse RCU") from the tip tree.

The net tree commit looks like a superset of the tip tree commit, so I
effectively reverted the tip tree commit.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__21_Jun_2010_16_16_09_+1000_NEGrOnCn9kXH9th6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkwfA6kACgkQjjKRsyhoI8wegQCgr4/t9h1BRhdYciQ7nJhDUVMx
90QAmgIdEfl3Jv6rN/sXnoNwC93wL9Xk
=TIs3
-----END PGP SIGNATURE-----

--Signature=_Mon__21_Jun_2010_16_16_09_+1000_NEGrOnCn9kXH9th6--
