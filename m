From: Valdis.Kletnieks@vt.edu
Subject: Re: 2.6.24-rc6-mm1 - oddness with IPv4/v6 mapped sockets hanging...
Date: Mon, 14 Jan 2008 18:04:28 -0500
Message-ID: <4382.1200351868@turing-police.cc.vt.edu>
References: <30887.1200209733@turing-police.cc.vt.edu> <32065.1200334930@turing-police.cc.vt.edu> <1030.1200336639@turing-police.cc.vt.edu>
            <200801141407.46345.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1200351868_2904P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:43954 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752160AbYANXEk (ORCPT
	<RFC822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 18:04:40 -0500
In-Reply-To: Your message of "Mon, 14 Jan 2008 14:07:46 EST."
             <200801141407.46345.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1200351868_2904P
Content-Type: text/plain; charset=us-ascii

On Mon, 14 Jan 2008 14:07:46 EST, Paul Moore said:
>
> http://git.infradead.org/?p=users/pcmoore/lblnet-2.6_testing;a=commitdiff;h=02f1c89d6e36507476f78108a3dcc78538be460b

Initial testing indicates that 2.6.24-rc6-mm1 plus this one commit is
behaving itself correctly - my Tcl test case that reliably demonstrated wedges
during SYN handling is definitively fixed, and the current issue with hangs with
data pending seems to be gone as well (after admittedly light testing).

Thanks for finding the commit that fixed it... 

--==_Exmh_1200351868_2904P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.8 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFHi+p8cC3lWbTT17ARAl9WAKC9VSshufAvQRsrvJ7U4xLeIjLaCgCePNCJ
PKagwt2RJ0bmSySO6ok1uas=
=fWsE
-----END PGP SIGNATURE-----

--==_Exmh_1200351868_2904P--
