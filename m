From: Valdis.Kletnieks@vt.edu
Subject: Re: 2.6.24-rc6-mm1 - oddness with IPv4/v6 mapped sockets hanging...
Date: Mon, 14 Jan 2008 11:15:38 -0500
Message-ID: <7197.1200327338@turing-police.cc.vt.edu>
References: <30887.1200209733@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1200327338_3131P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:37607 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbYANQPn (ORCPT
	<RFC822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 11:15:43 -0500
In-Reply-To: Your message of "Sun, 13 Jan 2008 02:35:33 EST."
             <30887.1200209733@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1200327338_3131P
Content-Type: text/plain; charset=us-ascii

On Sun, 13 Jan 2008 02:35:33 EST, Valdis.Kletnieks@vt.edu said:

> I'm seeing problems with Sendmail on 24-rc6-mm1, where the main Sendmail is
> listening on ::1/25, and Fetchmail connects to 127.0.0.1:25 to inject mail it
> has just fetched from an outside server via IMAP - it will often just hang and
> not make any further progress. Looking at netstat shows something interesting:
> 
> % netstat -n -a -A inet | grep 25
> tcp        0   5108 127.0.0.1:59355             127.0.0.1:25                ESTABLISHED 

The IPv6 is apparently a red herring - this morning I'm seeing the same problem
with another totally separate pair of programs that are IPv4-only, hanging
on loopback.

--==_Exmh_1200327338_3131P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.8 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFHi4qqcC3lWbTT17ARAuYSAKCWuGdoG2L7WQouMM8j0JydjkEJpQCg7qmT
u0koDo54Oa1lLgWWNRCVaec=
=F8Rx
-----END PGP SIGNATURE-----

--==_Exmh_1200327338_3131P--
