From: Michael Wu <flamingice@sourmilk.net>
Subject: merging adm8211
Date: Wed, 2 Mar 2005 20:57:16 -0500
Message-ID: <200503022057.24558.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5143523.WKJVzsIpdb";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart5143523.WKJVzsIpdb
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,
 I've been looking at the recent 802.11 work in the -mm tree, and it's look=
ing=20
good so far. However, it doesn't seem to have the authentication/=20
association/scanning stuff that the adm8211 needs. I remember that was=20
suppose to be done in userspace, but the current code doesn't seem to have=
=20
anything like it.

 So.. is any work being done on it? Does that code have to be strictly in=20
userspace? I'm not sure I like having to run a daemon for only certain=20
wireless cards. I'd rather have a minimal set of 802.11 station/management=
=20
functionality in the kernel for basic managed/adhoc/monitor/WEP features,=20
while restricting the use of WPA/HostAP/etc. to userspace. But, I have no=20
problems either way. I'd just like to know the current state of things and=
=20
what people are working on..

Thanks,
=2DMichael Wu

--nextPart5143523.WKJVzsIpdb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCJm8EyWWBbDEe0UIRAlMQAKCYZ9BUkP3OKxDHdlF+VQQEkTrYxQCgtDh+
uK2NfPbpMB2rSbTYr456EoI=
=pMvE
-----END PGP SIGNATURE-----

--nextPart5143523.WKJVzsIpdb--
