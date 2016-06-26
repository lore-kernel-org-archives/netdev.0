From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH ethtool 1/2] configure.ac: Remove feature test for
 <sys/ioctl.h>
Date: Sun, 26 Jun 2016 16:47:47 +0100
Message-ID: <20160626154747.GD7555@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="u3KzC5IXcIj3OgFK"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57912 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751265AbcFZPru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 11:47:50 -0400
Received: from ben by shadbolt.decadent.org.uk with local (Exim 4.84_2)
	(envelope-from <ben@decadent.org.uk>)
	id 1bHCHj-0008D7-H6
	for netdev@vger.kernel.org; Sun, 26 Jun 2016 16:47:47 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--u3KzC5IXcIj3OgFK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

<sys/ioctl.h> has been a hard dependency for as back as git history
goes (2005, shortly after version 3).

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
I spotted this while reviewing David Decotigny's patch to use netlink
sockets.

Ben.

 configure.ac | 1 -
 1 file changed, 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 3105415be026..6ebffedc9f5b 100644
--- a/configure.ac
+++ b/configure.ac
@@ -15,7 +15,6 @@ AM_PROG_CC_C_O
 dnl Checks for libraries.
=20
 dnl Checks for header files.
-AC_CHECK_HEADERS(sys/ioctl.h)
=20
 dnl Checks for typedefs, structures, and compiler characteristics.
 AC_MSG_CHECKING([whether <linux/types.h> defines big-endian types])


--u3KzC5IXcIj3OgFK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBV2/5I+e/yOyVhhEJAQpYJw//a3rt4WYB/dKFAXpBNuals3s6+2U7VkZk
pQ0n4dJ7i26YrELmcgOazcBxvLw5CIMvthjaTSRbrsucK84uUjAsM/RsRGp7b4O8
NY4ai0ELsxllQqUVFHlSGdQJqfsGBjg5e/qvyCkfEKjta8fiUKhp3gu0ayJwIg+a
puqhw5oAq9L3YDGTPde32RyBPwPcuMgE+MZinOH/XVVZVCnZ+hvqgkkhIGRs+ayS
/7hyVGpId87SVBB47oUoRT/8tgDULbJnwlzy5Dbd+33QUnNaTnNZ1fYhFBcnpOJZ
JJcaNAZHso7CVKc/lQo9R12qCS1V7P9Uj58/nQ5mA0N/GGjFLL5bWLIsKpwHzb7n
ANLMjFSQRNpgClb/GXqP4CCGt1jwg80MLKvngUqd5/vm5K/vlUOOC9FrqGud634+
x0mHdEVL/yVo/CASLZcHUBwQdiH+MnnTEiARYJfg8bG29YcvJAaP8VGf13Hskq7T
I9QPM7W/oqeJKKnTyz/H/FciTTlln/o3FKr8P3C4SKp+7iI9QGnSADubb9n0awJK
rKHR3zKgvxLutDZcxRyge3cvYRS+hJQWW2M/kCDmlwZeT50R/xVYioQ+JSjSFzeN
LKHh+vEtOI/0LKSGbDjOupOnmle2SxJf3YdxyLfcqaCg5h5ARQ1cwdXQnuPJe114
All5E4SnMHk=
=CIpB
-----END PGP SIGNATURE-----

--u3KzC5IXcIj3OgFK--
