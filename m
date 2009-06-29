From: Markus Wick <markus@selfnet.de>
Subject: BugReport: "ip route local ..." outside the table 255 (local)
Date: Mon, 29 Jun 2009 18:46:16 +0200
Message-ID: <200906291846.20962.markus@selfnet.de>
References: <200906250238.40369.markus@selfnet.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1439432.3LJnYvq4h4";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.selfnet.de ([141.70.124.9]:39064 "EHLO mail.selfnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751073AbZF2Qq2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 12:46:28 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.selfnet.de (Postfix) with ESMTP id B7432B3606A
	for <netdev@vger.kernel.org>; Mon, 29 Jun 2009 18:46:29 +0200 (CEST)
Received: from mail.selfnet.de ([127.0.0.1])
 by localhost (mailtest.selfnet.de [127.0.0.1]) (amavisd-maia, port 10024)
 with ESMTP id 06630-03 for <netdev@vger.kernel.org>;
 Mon, 29 Jun 2009 18:46:29 +0200 (CEST)
Received: from degasus.localnet (degasus.vaih.selfnet.de [10.4.186.33])
	by mail.selfnet.de (Postfix) with ESMTPSA id 8CB54B36067
	for <netdev@vger.kernel.org>; Mon, 29 Jun 2009 18:46:29 +0200 (CEST)
In-Reply-To: <200906250238.40369.markus@selfnet.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1439432.3LJnYvq4h4
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

Hello

Has anybody tried it? I think it is a bug but I don't know where.
Perhaps the mistake is in the routing decision (or in the userspace=20
application). iptables trace shows the packages in the filter/input table.
Perhaps socket lookout?

Please can somebody try the following example and confirm it:

sudo ip route add local 192.168.56.0/24 dev eth0 table local
ping 192.168.56.1
## *succeed*

sudo ip route add local 192.168.57.0/24 dev eth0 table main
ping 192.168.57.1
## connect: Invalid argument

Thanks

Markus

--nextPart1439432.3LJnYvq4h4
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iQIcBAABAgAGBQJKSO/YAAoJEIJAXxkDX2HF6EIP/A03Mc9X82GuSqJiqiFEVoAU
UqvULRiOMI3I1itEKG5FIZcYgdUsYHFH+nxeBxpdv+wtDnzvIG7m64cFLiUPF7Tq
el6mxbnUBRDCfxdf5m8gLjOf6S1FOeQjqW8h89rw+ntl85TCKP2we7pg34JZ+b1a
U9doouBHTUHTM5TRx2P10nCRzr8EujLgYH9MmBxbF8RRHdypEnz8YXGDgURQAS37
vDA4TG+KgVDgCTjI2D0eHRBzdsIHLHXShdsG6OrSzcml0N8zshZ4mGPFXwP6z2yc
t5VrqgJNMgHUOtFFAGI9lGymAB18BMGH0qMssYh2i7bfs6X7F+PQg59+bpJWZc38
DMhfpd3EF+baKUFys1H2V1tDiKlLVRFBgRGhEQFI66J57c+rIP9jbpaaKvQms4XW
r3udnqYnwvyzAjZ72EUZ/2EMnMYysWGI+jyC7iwBmV6Dh1cRsdedxvI36Xk/FE0H
w+wRhfskZ66N9ywBqZ7VNCYxlx9mlRh1VL4KiGxBCqVXr4fIHlnFK3inDsJvx/V8
fgpaVyaA4ceQc97DgHe1c8Uof/B2CCPggYKfzI/UC5lGZiqas0fIR3riDHNnm49J
M7qeTydEuBZi++j5QAUdeZL0klUsM9y+KrZRtiKZyIUCFWg874YL20Hgl6Yo/TdS
fmCV5kJ/avvueCoeLcQk
=1zX9
-----END PGP SIGNATURE-----

--nextPart1439432.3LJnYvq4h4--
