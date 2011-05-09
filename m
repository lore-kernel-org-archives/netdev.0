From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the net tree
Date: Mon, 9 May 2011 13:46:13 +1000
Message-ID: <20110509134613.bcf0b017.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__9_May_2011_13_46_13_+1000_onZAw9CdIEFa.8vO"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__9_May_2011_13_46_13_+1000_onZAw9CdIEFa.8vO
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net tree, today's linux-next build (x86_64 allmodconfig)
produced this warning:

net/sctp/protocol.c: In function 'sctp_v4_xmit':
net/sctp/protocol.c:842: warning: format '%p' expects type 'void *', but ar=
gument 5 has type '__be32'
net/sctp/protocol.c:842: warning: format '%p' expects type 'void *', but ar=
gument 6 has type '__be32'

Caused by commit f1c0a276ea17 ("sctp: Don't use rt->rt_{src,dst} in
sctp_v4_xmit()").

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__9_May_2011_13_46_13_+1000_onZAw9CdIEFa.8vO
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJNx2OFAAoJEDMEi1NhKgbsoasH/AqFBoktKv5Z3KxqplzaJuam
qizpVU5zAhrHZ+s2P6Id7Cagqs7JY8upZzp+02wmiPJ5IBjN5pTOHnBbUDEahYY7
ZceV5R5BRJzo6olSVYsU+0wAhZ9faPLs8E9RhPBgRAmwEht9T8XUjNkAQJWnfuTd
sldDfsx52IMI7EiMZwqUvn+JB73tffU+qynb8oYXZnnEFvdmO6VmDoKE7p0Gz7Aj
vePb/ssG8CF8nMo62JtvQK3ITsda5ms5KZlHoGqpwG2btxTUqGt6xZIDkXW5UuXI
Z3n5JbY6ieJTcUWtPykQZj+/VPhoLblocrXPeDyhmRVuvsQxlwR9ylVbr2X/4CE=
=zscc
-----END PGP SIGNATURE-----

--Signature=_Mon__9_May_2011_13_46_13_+1000_onZAw9CdIEFa.8vO--
