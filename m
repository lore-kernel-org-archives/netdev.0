From: Hugo Santos <hsantos@av.it.pt>
Subject: Re: [RFC] Mobile IPv6 introduction
Date: Wed, 2 Aug 2006 01:58:49 +0100
Message-ID: <20060802005849.GK8334@innerghost.net>
References: <44CB2914.9010803@linux-ipv6.org> <20060729141244.GJ8334@innerghost.net> <20060801.173535.38709014.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cO2ZlOvi7VNgmdOy"
Cc: nakam@linux-ipv6.org, yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi,
	vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av.it.pt ([193.136.92.53]:46813 "EHLO av.it.pt")
	by vger.kernel.org with ESMTP id S1750882AbWHBA6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 20:58:51 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060801.173535.38709014.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--cO2ZlOvi7VNgmdOy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

David,

On Tue, Aug 01, 2006 at 05:35:35PM -0700, David Miller wrote:
> This is partly why the multiple routing table code is being
> added as the initial infrastrucutre, so that source based
> things are possible.

   There have been other approaches for partial source-based stuff. For
 instance, in my tree i brought Subtrees back to a point of being
 usable. But what i was refering to was route-caching (some places only
 check cookies based on dst because we "don't support source routing"),
 APIs, etc. A few mails back you pointed the extension of a public
 structure to include a "source" attribute -- this is the kind of stuff
 we must add and that i think it's an independent work (read: even if
 the rest isn't merged, this should).

   Still regarding Subtrees, is there any interest in revitalizing that
 code? I have a couple patches that i could submit.

> Such a scheme would need provisions for handling the case where
> the user eats the message, but never tells us what to do.
> In such a case we'd need to emit some kind of ICMPv6 message,
> even if it would be just a timeout generated parameter problem.

   As i see it, the moment there is a raw socket open for dealing with a
 particular protocol, whoever opened that socket (handling the protocol)
 is responsible of generating any error messages associated with the
 protocol running.  Which is the case, the kernel shouldn't need to know
 whether any of the Mobile IPv6 specific messages have problems. The
 particular patch i was refering to does partial MIPv6 message
 processing inside the kernel before handing it to the socket as you
 only have access to the full received headers there.

> Such a layer would be needed if we ever put some kernel level
> components of Mobile IPv4 into the tree, which I see no reason
> not to, since it has this route optimization as well.

   Yes, the functionality is needed. My only problem is with exposing
 MODE_ROUTEOPTIMIZATION, it isn't modular. But it's something i can live
 with.

   Hugo

--cO2ZlOvi7VNgmdOy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFEz/jJ7asb/itUNKwRAozyAJ0ccr1uCkvGx2V4laoctNyTYcMhTACeIRlX
MTaAPzy6ZgsDvRjtfRp1phU=
=P9cj
-----END PGP SIGNATURE-----

--cO2ZlOvi7VNgmdOy--
