From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH 1/3] Security: Add prctl(PR_{GET,SET}_NETWORK) interface. (v2)
Date: Thu, 17 Dec 2009 23:43:58 -0500
Message-ID: <24998.1261111438@localhost>
References: <20091218030056.GC3047@heat>
            <20091218032957.GA23514@heat>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1261111438_3855P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Mark Seaborn <mrs@mythic-beasts.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
To: Michael Stone <michael@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:52001 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbZLREqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 23:46:06 -0500
In-Reply-To: Your message of "Thu, 17 Dec 2009 22:29:57 EST."
             <20091218032957.GA23514@heat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1261111438_3855P
Content-Type: text/plain; charset=us-ascii

On Thu, 17 Dec 2009 22:29:57 EST, Michael Stone said:
> Daniel Bernstein has observed [1] that security-conscious userland processes
> may benefit from the ability to irrevocably remove their ability to create,
> bind, connect to, or send messages except in the case of previously connected
> sockets or AF_UNIX filesystem sockets. We provide this facility by implementing
> support for a new prctl(PR_SET_NETWORK) flag named PR_NETWORK_OFF.

Dan does indeed have a point - but is this better achieved via either
the already-existing LSM interfaces (opening the stacking-LSM can of worms
again), or the SECCOMP framework?  We already have 2 other ways to turn off
stuff, do we really want a third way?

Alternatively, could a more generalized prctl interface be leveraged to handle
SECCOMP, and/or other targeted things that want to stack with LSM?


--==_Exmh_1261111438_3855P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFLKwiOcC3lWbTT17ARAlQXAKC6d81avJ04SnI9WNH2f9q7Gi1FogCg7ul0
zgcYrz/N6wcSMy+vxvxC0dI=
=iwSI
-----END PGP SIGNATURE-----

--==_Exmh_1261111438_3855P--

