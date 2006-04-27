From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 22/32] rt2x00: Allocate ring structures in single array
Date: Fri, 28 Apr 2006 00:03:13 +0200
Message-ID: <200604280003.14287.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3715162.7rb1dEp2d7";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.190]:44908 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751798AbWD0WCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:02:15 -0400
Received: by nproxy.gmail.com with SMTP id x30so1388639nfb
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:02:15 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3715162.7rb1dEp2d7
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

From: Ivo van Doorn <IvDoorn@gmail.com>

Allocate all ring structures seperately and
as an array of rings. This will make the
rt2x00_pci and rt2x00_usb structures more generic
for all rt2x00 modules.
Use seperate function to convert a dscape ring ID
to the address of the actual ring.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

Available on server:

http://mendiosus.nl/rt2x00/rt2x00-22-rings.diff

--nextPart3715162.7rb1dEp2d7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+iaqndE37Em0gRAqfbAJ4jTbZrLkGt8Ua4Yh4NQMZIFjbBAACePige
pN9T4xzXJswiL2RjG8ALHvs=
=vqzD
-----END PGP SIGNATURE-----

--nextPart3715162.7rb1dEp2d7--
