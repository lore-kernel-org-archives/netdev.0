From: Sven Eckelmann <sven@narfation.org>
Subject: Re: [B.A.T.M.A.N.] pull request: batman-adv 2011-03-05
Date: Sat, 5 Mar 2011 15:13:26 +0100
Message-ID: <201103051513.30796.sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1465142.ctbB09opI6";
  protocol="application/pgp-signature";
  micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: b.a.t.m.a.n@lists.open-mesh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:38890 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750853Ab1CEONf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 09:13:35 -0500
In-Reply-To: <1299328122-21468-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1465142.ctbB09opI6
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On Saturday 05 March 2011 13:28:14 Sven Eckelmann wrote:
> Hi,
>=20
> I was asked to submit following pull request for net-next-2.6/linux-2.6.3=
9.
> It contains Marek's hard work (and of course related work by other people)
> to remove the orig_hash (aka the batman-adv private "big kernel lock").

Small correction: The orig_hash is still there, but the orig_hash lock was=
=20
replaced by finer grained locking and rcu protected datastructures.

Kind regards,
	Sven

--nextPart1465142.ctbB09opI6
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJNckUIAAoJEF2HCgfBJntGSTUQANXmUVJnbep0gP/MRGj3RMGQ
9pv7snsrEMJ13+t5+cOBill565jKHMUswErkVDzmBOLdIHCAFmbWypp8Ul9/DYo2
2TKP0d6zT4wn8Qc279z80SN+a3+vgMNYbOsVal3G3zRYDk6IWhJo1v7tah1lAkcT
XGsAlI9XMRUP68/D6nINaPIRnKDpbJRVWehTFRijFhX23795lmRJuHSaPEis3FHU
TyOn9vQuSynqe/lafO1Mx5ivN1ime2loND0+IWCRdBH4EJmG4+NnxWkxmZFmswk+
blYGLVIQ251B5CxvbdjMtndVIvW8uR8ydE81Ou8G94zSwGZ1hxlM7g9xHjI28Gzt
1LCAf5/lS/FAWL9WCFJC+jFlDJF0ske6xGepDFmv+LfAcBpXVlxJEkoQSIsEINxm
4KVxCv9VKXq7b0xyOw9CCKrprnRlQSxtaIMn+m7lIh4vgElNZsQXD+7Wq4L6C74B
R8xdU+xES88ohmBrAgEoq5VgsR2NlKcS0Wlax1nDNg8edL2OD2PlhDZL08OqXAZB
zQ8rZXXRTQpHNl/Ac7B5iIrwa25Z4Xj+dqZGnyjYAoxf7c6O2ak7SUXs837XgsmM
QaDMA9esE3PuWW5j+7HCuK4dhd8BDwtJeJVR099bQKDWD7E85VpT990Ic5YpNcl6
jbl8OS5Dcu2NRA9FSbaR
=3Itd
-----END PGP SIGNATURE-----

--nextPart1465142.ctbB09opI6--
