From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [RFC PATCH 0/2] Hardware button support for Wireless cards
Date: Thu, 25 May 2006 17:15:54 +0200
Message-ID: <200605251715.58257.IvDoorn@gmail.com>
References: <!&!AAAAAAAAAAAuAAAAAAAAAFjEWUvexJtFsm0woXMZeHABAC4qy2+Ja65JmQuhL0/hqcgAAAAARPYAABAAAACMsnpvfH4iTKrBh6ONAHj7AQAAAAA=@serialmonkey.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1207336.gbBRd8z0Uu";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:49208 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S965197AbWEYPNZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 11:13:25 -0400
Received: by nf-out-0910.google.com with SMTP id a27so57104nfc
        for <netdev@vger.kernel.org>; Thu, 25 May 2006 08:13:24 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <!&!AAAAAAAAAAAuAAAAAAAAAFjEWUvexJtFsm0woXMZeHABAC4qy2+Ja65JmQuhL0/hqcgAAAAARPYAABAAAACMsnpvfH4iTKrBh6ONAHj7AQAAAAA=@serialmonkey.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1207336.gbBRd8z0Uu
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

As discussed previously on this list hardware button support
for wireless cards and Bluetooth devices could use a seperate
generalized driver.

I have made a first attempt to do this with the suggestions from the
discussion. This means that in all cases the hardware will be requested
to enable or disable the radio (if this command needs to be issued from
software) and it will send a signal to the input device created for the button.

At the moment a input device will be created for each registered button,
not sure if this is the desired situation, but thats why this is a RFC patch. ;)

I am also not sure where to place this driver so at the moment I have placed
it in /drivers/input/misc

The second patch is an example of the implementation in rt2x00.
That is just an example since that already contained a similar approach with
hardware button support.

All hints/tips/comments are welcome. :)

Ivo

--nextPart1207336.gbBRd8z0Uu
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEdcouaqndE37Em0gRAu1vAJ4+ssGa5cvuwjcueY3j/phwVqqMSwCfQT+z
Rxj80ISYSlyfvrQxLiCJiy0=
=llcY
-----END PGP SIGNATURE-----

--nextPart1207336.gbBRd8z0Uu--
