From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Subject: e1000e driver - commit  37b12910 needs to be in Linus tree..
Date: Tue, 18 Aug 2015 11:32:31 -0400
Message-ID: <2887.1439911951@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1439911951_2177P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound.smtp.vt.edu ([198.82.183.121]:35219 "EHLO
	omr2.cc.vt.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753332AbbHRPcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 11:32:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1439911951_2177P
Content-Type: text/plain; charset=us-ascii

Hate to bother everybody, but we're at -rc7..

Commit 83129b37ef is still in Linus's tree.  This one causes a crash
on my Dell Latitude after 4 hours uptime.

commit 83129b37ef35bb6a7f01c060129736a8db5d31c4
Author: Yanir Lubetkin <yanirx.lubetkin@intel.com>
Date:   Tue Jun 2 17:05:45 2015 +0300

    e1000e: fix systim issues

Commit 37b12910dd fixes it, but is *NOT* in Linus's tree yet.

commit 37b12910dd11d9ab969f2c310dc9160b7f3e3405
Author: Raanan Avargil <raanan.avargil@intel.com>
Date:   Sun Jul 19 16:33:20 2015 +0300

    e1000e: Fix tight loop implementation of systime read algorithm

Can we do something to get this fix in-tree, or revert the problem commit?




--==_Exmh_1439911951_2177P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVdNQDwdmEQWDXROgAQJGwQ//QmQncD6Xknd7BnINjTvhCP4UoxuhDfaS
73/6tDQPPzsOe3zQMKaFTrnLcHbXmeyzS6TGj/MRSZCUhuTWaPOqoH+bt/fzffX/
5hoJuFTeQqHpaGu6+qQFJKXTesjbUaNa67RSfF0yzkd/8Wc0q3vqqTLuUB4rSqz/
wxbiFaoXjeh7k1qy13aXsg83WbObqrDOj0nf49y1/ErLVawaBLJUZKyuurMhyn2A
0S3et4EX9SBzRIU2pWFoDs5Osurzg2MTzSsf6Tkei7pdSspCy95LCIXdCOqIoCnt
NlPLOU1GBh+yVY0P0YSRT9dDr4wh84RNSVLyhvl41TdWjmu++eeZE06rHksur3AP
HG/wT3WzoDYRqopCA5TBLU3kRbjxW9Jt5ZFTbBVN6GhWyYr6nq+Fw/E8JCIdK+lD
i9GLcKZv1diCJRhUOGdlahS2sj9SnuKu7CAHapHPcF7jq7TYlUhW/ovyXJMR1DOw
JCz8GnFRndXj8nslOHJv/UNHMZRmI7qwZtDI309SJLmL7ljlAf9RBJKCYJP9xKb+
VKfEWaDmAejUzxVMHz+akQ9nTgBzoxTR+DBwNwNSeaHZLqXZzYCfrbSOH1EGc5x1
B/MF3Q4/6xHgDaJlZPePHtM4va0+otSh5Hvxv6lQSAdnyHk3o/glieHKt/DbUlIE
R5mrolCH58o=
=Nvuf
-----END PGP SIGNATURE-----

--==_Exmh_1439911951_2177P--
