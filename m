From: martin f krafft <madduck@madduck.net>
Subject: why does promote_secondaries default to off? (was: iproute2:
	removing primary address removes secondaries)
Date: Fri, 11 Jan 2008 18:26:41 +0100
Message-ID: <20080111172641.GA22449@piper.oerlikon.madduck.net>
References: <20080111163155.GA17637@piper.oerlikon.madduck.net> <4787A3AB.4000205@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="PNTmBPCT7hxwcZjr"
To: netdev discussion list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seamus.madduck.net ([213.203.238.82]:54834 "EHLO
	seamus.madduck.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759759AbYAKR0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 12:26:46 -0500
Received: from wall.oerlikon.madduck.net (84-75-158-163.dclient.hispeed.ch [84.75.158.163])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client CN "wall.oerlikon.madduck.net", Issuer "CAcert Class 3 Root" (verified OK))
	by seamus.madduck.net (postfix) with ESMTP id DB5CA4060AA
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 18:26:51 +0100 (CET)
Received: from piper.oerlikon.madduck.net (piper.oerlikon.madduck.net [192.168.14.3])
	by wall.oerlikon.madduck.net (Postfix) with ESMTP id 5E8A49F13A
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 18:26:41 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <4787A3AB.4000205@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

also sprach Daniel Lezcano <dlezcano@fr.ibm.com> [2008.01.11.1813 +0100]:
> There is a tweak in /proc/sys which activate secondaries promotion when a=
=20
> primary is deleted.
>
> /proc/sys/net/ipv4/conf/all/promote_secondaries
>
> I think it changes the behavior to the one you wish.

Totally. That would have been the last place I had looked.
Thank you!

Do you have any idea why this isn't on by default?

--=20
martin | http://madduck.net/ | http://two.sentenc.es/
=20
"i never go without my dinner. no one ever does, except vegetarians
 and people like that."
                                                        -- oscar wilde
=20
spamtraps: madduck.bogus@madduck.net

--PNTmBPCT7hxwcZjr
Content-Type: application/pgp-signature; name="digital_signature_gpg.asc"
Content-Description: Digital signature (see http://martin-krafft.net/gpg/)
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHh6bRIgvIgzMMSnURAn7LAJ9fHlSPcFi4W0eDJke3pp2tIcNL6ACffO1I
K3MFGkzcislVfjy8DAOD6Ys=
=pPCA
-----END PGP SIGNATURE-----

--PNTmBPCT7hxwcZjr--
