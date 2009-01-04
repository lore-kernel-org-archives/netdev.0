From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH] printk: Let %pR handle NULL pointers
Date: Sun, 04 Jan 2009 00:14:34 -0500
Message-ID: <25339.1231046074@turing-police.cc.vt.edu>
References: <1230979341-23029-1-git-send-email-xyzzy@speakeasy.org> <alpine.LFD.2.00.0901030905140.3179@localhost.localdomain> <1231019614.15389.104.camel@pasglop>
            <Pine.LNX.4.58.0901031827380.25853@shell2.speakeasy.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1231046074_3941P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Harvey Harrison <harvey.harrison@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Trent Piepho <xyzzy@speakeasy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:54648 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750696AbZADFOp (ORCPT
	<RFC822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 00:14:45 -0500
In-Reply-To: Your message of "Sat, 03 Jan 2009 21:02:15 PST."
             <Pine.LNX.4.58.0901031827380.25853@shell2.speakeasy.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1231046074_3941P
Content-Type: text/plain; charset=us-ascii

On Sat, 03 Jan 2009 21:02:15 PST, Trent Piepho said:
> resource pointer.  Maybe "[]" or "[-]" would be better?  A null MAC address
> could be ":::::" or "x:x:x:x:x:x".  "N.U.L.L" or "x.x.x.x" for a null IP4
> address.  And so on.  So the printout looks nicer when a NULL pointer isn't
> a bug.

Have to be careful for IPv6 addresses - '::' is a legal representation of
an all-zeros address.  Also, N.U.L.L. may give indigestion to logfile parsers
that are expecting a numeric value in the IP address.  It's however unclear
whether we should pick something that doesn't have 3 periods in it, so it
can't match, or whether *that* will give regexp-based logfile readers
indigestion when they don't pick up an IP address where they expected...

Do we want the %pI6 format to do the multiple-zeros -> :: compression?

(Adding netdev to cc: list)

--==_Exmh_1231046074_3941P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFJYEW6cC3lWbTT17ARAqHPAKDJd8+pX/d9vaE+upxUnvugZTkChACeKDV2
9yL+W/e+UCN7EiCsYuetDfU=
=zor+
-----END PGP SIGNATURE-----

--==_Exmh_1231046074_3941P--
