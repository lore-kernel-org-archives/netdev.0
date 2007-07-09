From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: Re: [PATCH] Fix kernel unaligned access with r8169 on sparc64
Date: Mon, 9 Jul 2007 14:57:48 +0200
Message-ID: <200707091457.49034.florian.fainelli@telecomint.eu>
References: <200707061502.49146.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2052357.xQzgidTQqN";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-ext.int-evry.fr ([157.159.11.17]:34683 "EHLO
	smtp-ext.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917AbXGIM5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 08:57:48 -0400
Received: from [192.168.10.156] (mla78-1-82-240-17-188.fbx.proxad.net [82.240.17.188])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp-ext.int-evry.fr (Postfix) with ESMTP id 0364A8D1695
	for <netdev@vger.kernel.org>; Mon,  9 Jul 2007 14:57:47 +0200 (CEST)
In-Reply-To: <200707061502.49146.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2052357.xQzgidTQqN
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46ew things about this patch. It's pretty quick and dirty, more experience=
d=20
people with a better knowledge of the ip stack would certainly do better.
Though the problem was reported with Debian's 2.6.18 kernel, it is also=20
present in the 2.6.22-rc6 version.

Without the patch, I can hardly achieve 130Mbits between two sparcs on a=20
dedicated r8169 link, with it we can achieve 300 Mbits, though it's not=20
purely GigE, it's still three times better. Measures were made using iperf.

--nextPart2052357.xQzgidTQqN
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.5 (GNU/Linux)

iD8DBQBGkjDNmx9n1G/316sRAsndAJ4ta+Bf3KyOBSUbqrzbXt0Aw6fKfgCgl0Y9
ZzhxecQz/JUEKqxkzx8ktR4=
=aHd0
-----END PGP SIGNATURE-----

--nextPart2052357.xQzgidTQqN--
