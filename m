From: Valdis.Kletnieks@vt.edu
Subject: Re: 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Tue, 17 Feb 2009 23:41:16 -0500
Message-ID: <25143.1234932076@turing-police.cc.vt.edu>
References: <alpine.LFD.2.00.0902131413120.3179@localhost.localdomain> <20090217095232.5da06b9f@werewolf.home> <200902172001.41804.arvidjaar@mail.ru>
            <20090217.142946.232071526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1234932076_24816P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: arvidjaar@mail.ru, rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:37453 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394AbZBRElt (ORCPT
	<RFC822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 23:41:49 -0500
In-Reply-To: Your message of "Tue, 17 Feb 2009 14:29:46 PST."
             <20090217.142946.232071526.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1234932076_24816P
Content-Type: text/plain; charset=us-ascii

On Tue, 17 Feb 2009 14:29:46 PST, David Miller said:
> Don't configure ipv6 into your kernel, really.
> 
> There is no other way to handle this.  If we want to support
> IPV6 layer things in the bonding driver, it is going to
> call helper functions in the ipv6 module and therefore must
> be able to load it and use functions in it.

What does a poor corporate user do if they're running a distro kernel that
was built with CONFIG_IPV6, but local security policy says "Disable IPv6
because we don't do it yet, or because it breaks mission-critical software
package XYZ?"  There's a *lot* of people who implement that by the "block
the ipv6 module from loading" trick.  And building a kernel that doesn't
include IPv6 may not be feasible due to vendor certification issues...

Heck, *I*'m almost in that boat - probably need to use bonded ethernet on some
servers because we can't get 10GigE, but the software used in the project the
servers were bought for blows chunks if it gets a whiff of an IPv6 address.
Ended up spending 3 weeks doing a massive kludgery of one sort in DNS for the
rest of the world, and equally massive lying in /etc/hosts for the hosts...
(Don't ask - it was long and ugly, and just disabling the module would have
saved me about 2.95 weeks of work, so I know where those people are coming
from...)


--==_Exmh_1234932076_24816P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFJm5FscC3lWbTT17ARAmFnAJ46BE3kV9h1kZLcYLhqIrEphKp0RwCgj80g
PgM/6vuh1jZa4w9AY/UWO2k=
=RzbE
-----END PGP SIGNATURE-----

--==_Exmh_1234932076_24816P--
