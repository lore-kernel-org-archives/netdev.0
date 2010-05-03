From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Mon, 3 May 2010 12:08:47 +1000
Message-ID: <20100503120847.e9328e75.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__3_May_2010_12_08_47_+1000_n.cQ3o_A7JLrLBy+"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Wei Yongjun <yjwei@cn.fujitsu.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__3_May_2010_12_08_47_+1000_n.cQ3o_A7JLrLBy+
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

After merging the net tree, today's linux-next build (x86_64
allmodconfig) failed like this:

net/sctp/socket.c: In function 'sctp_data_ready':
net/sctp/socket.c:6191: error: implicit declaration of function 'sk_has_sle=
eper'
net/sctp/socket.c:6192: error: 'struct sock' has no member named 'sk_sleep'

Caused by commit 43815482370c510c569fd18edb57afcb0fa8cab6 ("net:
sock_def_readable() and friends RCU conversion") interacting with commit
561b1733a465cf9677356b40c27653dd45f1ac56 ("sctp: avoid irq lock inversion
while call sk->sk_data_ready()") which entered Linus' tree on April 29.

I have used the net tree from next-20100430 for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__3_May_2010_12_08_47_+1000_n.cQ3o_A7JLrLBy+
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkveMC8ACgkQjjKRsyhoI8xU3ACfQZlEsx2RaLMFnQcWWTjuE252
XAMAoIgXRntVsXBN63fupS7DkMugi+Zv
=ytvm
-----END PGP SIGNATURE-----

--Signature=_Mon__3_May_2010_12_08_47_+1000_n.cQ3o_A7JLrLBy+--
