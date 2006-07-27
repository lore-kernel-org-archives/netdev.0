From: Hugo Santos <hsantos@av.it.pt>
Subject: Regarding offloading IPv6 addrconf and ndisc
Date: Thu, 27 Jul 2006 12:25:31 +0100
Message-ID: <20060727112531.GN6026@innerghost.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uMPAU7A2Er6+wvsD"
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av.it.pt ([193.136.92.53]:17796 "EHLO av.it.pt")
	by vger.kernel.org with ESMTP id S1751278AbWG0LZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 07:25:33 -0400
To: yoshfuji@linux-ipv6.org, davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--uMPAU7A2Er6+wvsD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi all,

   In the same line as some of the recent IPv6 patches being submited
 for comments, and taking into consideration RFCs such as 'SEcure
 Neighbor Discovery (SEND)' (RFC 3971) and 'Cryptographically Generated
 Addresses (CGA)' (RFC 3972) where the complexity associated with
 maintaining addresses and performing neighbor discovering increases
 considerably, what would be the possibility of inclusion of code that
 would allow the outsource of address configuration, DAD and neighbor
 discovery to a user-space control application (being that the first two
 can already be somewhat outsourced)? Of course that the final decision
 is always based on the patch itself but i would like to probe the
 developers about the possibility of ever merging such code. Personally
 i believe that this kind of control logic should always be in
 user-space to allow for greater flexibility -- but i'm aware that lots
 of people prefer to have it in kernel to minimize deployment
 dependencies.

    Comments?

    Hugo

--uMPAU7A2Er6+wvsD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFEyKKr7asb/itUNKwRAv0WAJwMc4SUg1HUa+ezdTtX+zAPgOEctACgm236
OXdj8kCK2SSO73hIwmN2cxA=
=RJDh
-----END PGP SIGNATURE-----

--uMPAU7A2Er6+wvsD--
