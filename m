From: Ulrich Weber <uweber@astaro.com>
Subject: Re: IPv6 Anycast?
Date: Fri, 23 Jul 2010 18:29:06 +0200
Message-ID: <4C49C352.6010701@astaro.com>
References: <4C48B90B.60304@actusa.net> <alpine.DEB.1.10.1007230554240.9875@uplift.swm.pp.se> <4C491AD4.9070103@actusa.net> <alpine.DEB.1.10.1007230748380.9875@uplift.swm.pp.se> <4C49B163.8090400@actusa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mikael Abrahamsson <swmike@swm.pp.se>, netdev@vger.kernel.org
To: Stuart Sheldon <stu@actusa.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-64.dex002.intermedia.net ([64.78.20.13]:47986 "EHLO
	dhost002-64.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752781Ab0GWQoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 12:44:20 -0400
In-Reply-To: <4C49B163.8090400@actusa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi Stuart,

you probably mean the IPV6_JOIN_ANYCAST/IPV6_LEAVE_ANYCAST socket optio=
n
support? See the old patch documentation:
http://lkml.indiana.edu/hypermail/linux/net/0208.3/0028.html

To remove the automatic generated IPv6 Anycast addresses, you can remov=
e
the routes from the local table manually:
ip -6 route del 2607:ff38:: table local

Best regards
 Ulrich

- --=20
Ulrich Weber | uweber@astaro.com | Software Engineer
Astaro GmbH & Co. KG | www.astaro.com | Phone +49-721-25516-0 | Fax =96=
200
An der RaumFabrik 33a | 76227 Karlsruhe | Germany
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkxJw1IACgkQ22t2oTuElzpt9ACfYR7cZ2tWRb9kVuvTl3d8nbkn
oCUAmwVQYjBJ9a35yA/UyJdLeti8cNWK
=3DUDP7
-----END PGP SIGNATURE-----
