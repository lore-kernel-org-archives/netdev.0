From: Sven Eckelmann <sven@narfation.org>
Subject: Re: [PATCH 03/17] batman-adv: Add network_coding and mcast sysfs files to README
Date: Sat, 29 Oct 2016 12:37:07 +0200
Message-ID: <22392280.4UY6GoIrAk@sven-edge>
References: <20161027190150.7880-1-sw@simonwunderlich.de> <20161027190150.7880-4-sw@simonwunderlich.de> <20161029103301.GD1692@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1574380.fsPvYCkOo9"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: Simon Wunderlich <sw@simonwunderlich.de>, davem@davemloft.net,
        netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:41790 "EHLO v3-1039.vlinux.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752638AbcJ2KhQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Oct 2016 06:37:16 -0400
In-Reply-To: <20161029103301.GD1692@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1574380.fsPvYCkOo9
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Samstag, 29. Oktober 2016 12:33:01 CEST Jiri Pirko wrote:
[...]
> >--- a/Documentation/networking/batman-adv.txt
> >+++ b/Documentation/networking/batman-adv.txt
> >@@ -71,10 +71,11 @@ All  mesh  wide  settings  can be found in batman's own interface
> > folder:
> > 
> > # ls /sys/class/net/bat0/mesh/
> >-#aggregated_ogms        distributed_arp_table  gw_sel_class    orig_interval
> >-#ap_isolation           fragmentation          hop_penalty     routing_algo
> >-#bonding                gw_bandwidth           isolation_mark  vlan0
> >-#bridge_loop_avoidance  gw_mode                log_level
> >+# aggregated_ogms        fragmentation  isolation_mark  routing_algo
> >+# ap_isolation           gw_bandwidth   log_level       vlan0
> >+# bonding                gw_mode        multicast_mode
> >+# bridge_loop_avoidance  gw_sel_class   network_coding
> >+# distributed_arp_table  hop_penalty    orig_interval
> 
> I strongly believe it is a huge mistake to use sysfs for things like
> this. This should be done via generic netlink api.

This doesn't change the problem that it is already that way. This patch
only adds the list of available files to the README.

Kind regards,
	Sven

--nextPart1574380.fsPvYCkOo9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJYFHvTAAoJEF2HCgfBJntGFuIP/RZXfs4zr6H3ybp7CuAqZyDw
kglrfbl2W+SDF8sinXmkxEZ10ixdm15/BJWyLiobjpN/GRHe5uVBO3cWJFkI5uXC
eEMFgsIxJiVsVHhpqgv40eXPLOguSOKn8WhIKAUqII5WoKnbv1sJ/uexA+f7t3Gd
VuQUWU42kWKkSWapu+fdQyhYrzWGs6fU7v2ijbTVYyIImRS6vd9DvFrinK8Hjajb
+4NNC230Ijd5vNab4k6G/jW/vRoqZGHNoL0CsL3dJ6OHPZsrKiR9gXRQVX2cPSnS
qkujF7scFTD1aIHfKHtgqaMd3dHGAn9Y5AZvkVjtoQ989ERW8ynEoycS+CDgwgud
yhCvXL1INpnEWWRLlkaOqKriE0QVWlX1MmX446BVG2Fz5LelqiHJkYh7CMn+lGDE
aWpzTloQq/fhECfyxWfJodPzA+THO9wb9KYOwvKmACvB/HQke8p6/aYKp3IAheCe
E4saaOab9XNTRz5g2g/NF3oXPJhlHSdOMe5u0SGzwTuPopy1OBnlyNIse0NUOv8t
VaJhdngbR2PkPp88MZNURC1B3sfzhn63oFEJAr6CDS+2h+KQrcaiBUl/lIIa3RCv
TQFQGgjayZjVdbf8VqTRJcsWvfZH54xAckBwJwROcR6PkxTiV5rxnOxQYlqMJ4N/
k/74RMf5670mVaR1fUth
=DjY8
-----END PGP SIGNATURE-----

--nextPart1574380.fsPvYCkOo9--
