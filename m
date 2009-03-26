From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: net tree build warnings
Date: Thu, 26 Mar 2009 17:37:13 +1100
Message-ID: <20090326173713.ee63b803.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__26_Mar_2009_17_37_13_+1100_Xs6g7L5kXt1iz6/d"
Cc: linux-next@vger.kernel.org, Eric Leblond <eric@inl.fr>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__26_Mar_2009_17_37_13_+1100_Xs6g7L5kXt1iz6/d
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

Today's linux-next build (x86_64 allmodconfig) produced these warnings:

net/bridge/netfilter/ebt_log.c: In function 'ebt_log_init':
net/bridge/netfilter/ebt_log.c:230: warning: passing argument 2 of 'nf_log_=
register' discards qualifiers from pointer target type
net/bridge/netfilter/ebt_log.c: In function 'ebt_log_fini':
net/bridge/netfilter/ebt_log.c:236: warning: passing argument 1 of 'nf_log_=
unregister' discards qualifiers from pointer target type
net/bridge/netfilter/ebt_ulog.c: In function 'ebt_ulog_init':
net/bridge/netfilter/ebt_ulog.c:317: warning: passing argument 2 of 'nf_log=
_register' discards qualifiers from pointer target type
net/bridge/netfilter/ebt_ulog.c: In function 'ebt_ulog_fini':
net/bridge/netfilter/ebt_ulog.c:327: warning: passing argument 1 of 'nf_log=
_unregister' discards qualifiers from pointer target type

Caused by commit ca735b3aaa945626ba65a3e51145bfe4ecd9e222 ("netfilter:
use a linked list of loggers") which removed const from the "struct
nf_logger *" arguments.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__26_Mar_2009_17_37_13_+1100_Xs6g7L5kXt1iz6/d
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAknLIpkACgkQjjKRsyhoI8zjBACeJzmmlyx8/wHkQCT7WYNixVLu
mzUAoL3LrzT8sZfz7f1WdnRsJDIO+4B5
=x1jM
-----END PGP SIGNATURE-----

--Signature=_Thu__26_Mar_2009_17_37_13_+1100_Xs6g7L5kXt1iz6/d--
