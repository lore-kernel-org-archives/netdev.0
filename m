From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: CRC16 in rt2x00
Date: Sat, 27 May 2006 13:27:15 +0200
Message-ID: <200605271327.18879.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3518551.UZIiNBA83y";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:36758 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1750744AbWE0LYk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 May 2006 07:24:40 -0400
Received: by nf-out-0910.google.com with SMTP id l36so22396nfa
        for <netdev@vger.kernel.org>; Sat, 27 May 2006 04:24:39 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3518551.UZIiNBA83y
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

I have a small question about the CRC16 usage in rt2x00
and what the netdev preferred method is for this.

At the moment the rt2x00 drivers in wireless-dev use
its own CRC16 table and calculation inside the driver.
There already is a CRC16 library in the kernel
which uses the 0x8005 table, while rt2x00 uses the
0x1021 polynomial table.

Is keeping this version of CRC16 inside rt2x00 the most
sensible thing to do? Or should it be moved to the lib
folder of the kernel so other drivers could make use of it as well?
(So far I have not found a driver which makes use
of the same CRC16 table)

Thanks.

Ivo

--nextPart3518551.UZIiNBA83y
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEeDeWaqndE37Em0gRAtCOAJ432tZZH506UmSWKyMdg2mPfqYRCQCfS8MR
NP7SFGgc5vYqnWhcyyxSsmY=
=bBx1
-----END PGP SIGNATURE-----

--nextPart3518551.UZIiNBA83y--
