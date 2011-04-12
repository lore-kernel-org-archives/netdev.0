From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH RESEND] uts: Set default hostname to "localhost", rather than "(none)"
Date: Mon, 11 Apr 2011 22:47:26 -0400
Message-ID: <16567.1302576446@localhost>
References: <20110411050155.GA2507@feather>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1302576446_5348P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: Josh Triplett <josh@joshtriplett.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:45778 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756061Ab1DLCsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 22:48:06 -0400
In-Reply-To: Your message of "Sun, 10 Apr 2011 22:01:59 PDT."
             <20110411050155.GA2507@feather>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1302576446_5348P
Content-Type: text/plain; charset=us-ascii

On Sun, 10 Apr 2011 22:01:59 PDT, Josh Triplett said:

> Change the default hostname to "localhost".  This removes the need for
> the standard fallback, provides a useful default for systems that never
> call sethostname, and makes minimal systems that much more useful with
> less configuration.

Seems sane enough to me.  Only possible objection I can think of is "if you're running
with 'init=/bin/sh' or similar config too crippled to run /bin/hostname, maybe your
network config *should* be intentionally toasted so you can't get further surprises".

I personally don't agree - just saying somebody might hold that position.

--==_Exmh_1302576446_5348P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFNo70+cC3lWbTT17ARAtxLAJ9BnedAEgl1e2aWREXcwIqbIbH5eQCg2UKG
JpoAnnWNxvi4EjWolQAk1hw=
=Mx1t
-----END PGP SIGNATURE-----

--==_Exmh_1302576446_5348P--

