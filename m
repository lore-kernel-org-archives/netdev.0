From: Hugo Santos <hsantos@av.it.pt>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Thu, 27 Jul 2006 18:56:49 +0100
Message-ID: <20060727175649.GO6026@innerghost.net>
References: <20060727112531.GN6026@innerghost.net> <44C8B0B8.2010408@miyazawa.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2/+Vq7w28QOSGzSM"
Cc: yoshfuji@linux-ipv6.org, davem@davemloft.net,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av.it.pt ([193.136.92.53]:57488 "EHLO av.it.pt")
	by vger.kernel.org with ESMTP id S1751902AbWG0R4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 13:56:51 -0400
To: Kazunori Miyazawa <kazunori@miyazawa.org>
Content-Disposition: inline
In-Reply-To: <44C8B0B8.2010408@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--2/+Vq7w28QOSGzSM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

> I'm interested in the approach. And I have a couple of comments.
> I think DAD and ND are time critical operations.
> Can the daemons process with confirming to the specs.

   My tests indicate that yes, even when considering mobility scenarios
 where expected times are reduced. There is always the possibility of
 giving the process a priority high enough to work as well as possible
 in most usages.

> even if it were swapped out?

   Depending on the implementation, you may lock all or part of the
 process address space so it doesn't get swapped out.

> Can we prevent the oom killer from killing the daemons?

   I don't think we can prevent it, but we may adjust it's score via
 /proc/pid/oom_adj as it's likeness of being killed being very reduced.

> Anyway, we have to consider Pros. and Cons of the approach.

   As long as there is no impact in the current functionality and the
 changes which are required from an architectual POV are acceptable by
 the main developers, i don't see anything against.

   Waiting for input,

   Hugo

--2/+Vq7w28QOSGzSM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFEyP5h7asb/itUNKwRAgSpAJ4ogN3ayMQZ/PRr2fXfXUnzv20xqgCgoBbt
MRzoXFnQ9W++UH+SitBPb1I=
=0hY1
-----END PGP SIGNATURE-----

--2/+Vq7w28QOSGzSM--
