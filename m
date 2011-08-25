From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next v2 10/10] headers, can: Add missing #include to
 <linux/can/bcm.h>
Date: Thu, 25 Aug 2011 05:46:06 +0100
Message-ID: <1314247567.27179.127.camel@deadeye>
References: <1314247131.27179.116.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Jo/CpbbBnNYfiVLZgIkg"
Cc: netdev@vger.kernel.org, Oliver Hartkopp <socketcan@hartkopp.net>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:37357 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752159Ab1HYEqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 00:46:07 -0400
In-Reply-To: <1314247131.27179.116.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Jo/CpbbBnNYfiVLZgIkg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<linux/can/bcm.h> uses type canid_t, defined in <linux/can.h>.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>
---
 include/linux/can/bcm.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/can/bcm.h b/include/linux/can/bcm.h
index 1432b27..e96154d 100644
--- a/include/linux/can/bcm.h
+++ b/include/linux/can/bcm.h
@@ -15,6 +15,7 @@
 #define CAN_BCM_H
=20
 #include <linux/types.h>
+#include <linux/can.h>
=20
 /**
  * struct bcm_msg_head - head of messages to/from the broadcast manager
--=20
1.7.5.4



--=-Jo/CpbbBnNYfiVLZgIkg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATlXTjue/yOyVhhEJAQq7Bg//YfrSEs0tCAdIzRHNMNnK7B4noldTMkos
4wcaSx4g6PhNFA4bjkZXQfECO4suWc5yGdk9ct+PZrOLme6GjMb2OFo/6Af/eR3m
zz+x1td9MBsX7ZWJXOcC2Xwv4RitIepkhAfMRiz466Ca9k9EQsKp5/NDQ84T38hA
bBc019qcpEMjKbtZ04arRnZ7ezgqnGkzkvL3+Kcr5Rwya8OnKrc7R0sGZCVaWytb
RkM6blXzebrzLNQV7BcjA+v2fWJ6Of7SfVNtVwRJ+N4pELberrxXzdpMlKyH+BXX
xkFdA309oY415H9JKg/ZG6P72Jdb7GZAKzAlV49hCjvxpwOxrL3LHE8jS9rHsG/7
825HU+pnmYGORzegqdxu5bq3M45CSQnCIt/UcP/d380MCVaUVKpGkagW6aa/f1mz
sagO1bAn4k4vdjKq725ESalj96MoqpgKmbeFVsQWmYnmcFERL/E/6XB0w1IQb87B
LY2tc4+Vq43+vzniakr2fRehd9BSdYLu7CTwchL/1bRrUnLiT2BJ6Re0zG6OiEh0
n5OwPE0yQpGe+wUlfycFF2xYfUE45cPqdGTwq8Z5SUiNEW63Bumnw08Hh2QOkgWM
/vEUfV5HJzqajioiz2fwRNwd6IStms9Eq3OwpKocjthLDIxxc9ukpXgA5V+qUa3n
CE7z2gaGvfg=
=qZ6Z
-----END PGP SIGNATURE-----

--=-Jo/CpbbBnNYfiVLZgIkg--
