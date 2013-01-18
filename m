From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH] [iproute] ipxfrm: simplify algo code a bit
Date: Thu, 17 Jan 2013 23:00:09 -0500
Message-ID: <201301172300.10300.vapier@gentoo.org>
References: <1358476746-10810-1-git-send-email-vapier@gentoo.org> <20130117.222646.675735349628953028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3252984.sA4jc74CNU";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:43328 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753685Ab3ARD4g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 22:56:36 -0500
In-Reply-To: <20130117.222646.675735349628953028.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart3252984.sA4jc74CNU
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Thursday 17 January 2013 22:26:46 David Miller wrote:
> From: Mike Frysinger <vapier@gentoo.org>
> Date: Thu, 17 Jan 2013 21:39:06 -0500
> > The current code sets up a structure with xfrm_algo embedded in it, but
> > doesn't use the supplemental key field.  Drop it.
>=20
> It's for the storage of the zero length array at the end of
> xfrm_algo.

ok, so we can use alloca instead

> Don't change code you don't understand.

so you're just going to be pointlessly hostile everywhere ?  stop wasting=20
time.
=2Dmike

--nextPart3252984.sA4jc74CNU
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJQ+MjKAAoJEEFjO5/oN/WBqpkQAKfXMU3BljaiNMRQ8hcAYhmu
mdsvrHKl2k/uYtKSH5a7cM+wPMxq0uk56PSEdL5966se96RE6yaqXD80rNEKz4AT
5lev3mTpdg+5vtBN9v0+YK5tbI+B+8zsOdItggNbmB5dovZLKAo/S6dQmeAa51Di
UzyY4K1osOoQRDdxajazLXC4LMxLsS9IVp/5GRWu5T2eAY0eTCTo8E/Ll1yqZk9T
rWb1TsUzjT3C3b88qsCS+EH06HP154L9o7Ure/iviuuCSC0JI4YETpCvsCtEhQ30
uy/6Az6ux5ShU9Du+HVFR/nKMuAgkQ2qtQn7zIt9XQEl+9T4BtNjKhoBl5cKGlFL
JGYE57g5XFcVEXvV/84EUj8jns25it4IUJnGxF7N2K+oSzJjwwCcdBLM2Aq+SyHa
t5xBevq0g8/bfck2bfVcHPuvl1wo3qhVgxpzwVor7IWrTtjPPMAXpkful5nP+LNu
BlkNn1F1cCD/hs30z2A+UcKFzGtSWPsVqd9Xhh/B61vibTNHSSY5qSCntkhG1Jx8
fST/Xf/0SshEmEHAF4r/ZUPLeL5BE28lu1pNi+I3SouypdlKE/lpFlZsISTblDJd
9RS6rxu9uguSofji/o/D6dlM4LtPLDBycl9BS3I4LbXxBD5GnVyLl8oeeh2uf2sa
0uuxs7vCbTPFKQILHF3s
=n+sO
-----END PGP SIGNATURE-----

--nextPart3252984.sA4jc74CNU--
