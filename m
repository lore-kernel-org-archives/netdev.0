From: Sven Eckelmann <sven@narfation.org>
Subject: Re: Re: [B.A.T.M.A.N.] [PATCH 04/10] batman-adv: export compatibility version via debugfs
Date: Mon, 19 Nov 2012 21:25:23 +0100
Message-ID: <2101957.c21FspBRQs@sven-laptop.home.narfation.org>
References: <1353313451-2930-1-git-send-email-ordex@autistici.org> <5268262.CIrZ93ERtB@bentobox> <1353354018.4156.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1390365.niZB4vpOmQ"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	netdev@vger.kernel.org, Marek Lindner <lindner_marek@yahoo.de>,
	davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:40175 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754782Ab2KSUZd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2012 15:25:33 -0500
In-Reply-To: <1353354018.4156.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart1390365.niZB4vpOmQ
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="UTF-8"

On Monday 19 November 2012 19:40:18 Ben Hutchings wrote:
[...]
> > > I do hope that you're not planning to use unstable debugfs interfaces
> > > indefinitely.
> > 
> > Why are you refering to the adding of an file as "incompatible" debugfs
> > interface? I would call it additional information. And the rest of the
> > commit message is talking about *possible* protocol incompatibilies of
> > the network protocol (which caused this uncontrolled erruption of anger
> > in a network maintainer).
> 
> I didn't say that.  But debugfs tends to be exempted from expectations
> of interface stability or cleanliness (as it's for development, not
> production... right?).  It's also an optional feature that might not be
> enabled at compile time or run-time.  If BATMAN is ever going to be
> ready for general use it will need stable interfaces that are updated in
> a backward-compatible way and don't depend on debugfs.

Ok, I thought this file was meant for an optional developer information (the 
interface to work with batman-adv is in /sys) and concluded too fast that you 
are questioning this change because it makes something "unstable" (sry, for 
using the wrong term before).

Thanks,
	Sven
--nextPart1390365.niZB4vpOmQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQqpWzAAoJEF2HCgfBJntGVskQALB+Qb3QzenDoW2MwGYn1A3d
qg/64+Iiu92jVAdAUpPA7XIyHDAc2JmLPp4uWN3LOFO3Z9GN3yjt81bgbNFUg2Z7
rhWTrmt/ai8Ojp8Lqp28aM5un1DRJfBAmDQ8JcEZ8KgzdSd5WtRd6ibcfMcMryYO
oApGrDL0uELWgDCKNpbHz067B8qymp+lpXHTzZoaxZcm+lQ+r5z1LE6yRnilG/CK
i1atjZuZvxqTa/YZgVJDUqJFLSHMSkWnvoORsOEM0WdDx9xxkQ1fX580JWXS8M9/
bMz79SWI0AqGpbOku3EbmWD0pt8ZJ1HfuEgxpKhUsEJ32OUAcB+GlA6GAs95Er0m
/J/JYP3SlKex/q1xSSAv3/ik3AN66GGWZomxrMMyAbRHhTyaDd9mxQK0PRTkeYgp
PwRLiRjqssfwuioHfuUSNI0m4pygwNyuY4hBe3fTj27v4+ICBpMAOmYdiQRE0IZd
WVtdWM4HDw8ZNIzzEri0aa1zVxgvbd3GR9JBIeJ5UuaHNFLciBho4Il6OAavikVh
UWJFheZGKSpfrOECD251o4HEczjURqZxv8p/T6qsJObgM0zAZ692g9+Suj0w3kRT
VEDWTnU+Ai5fCYm82FHqRumUOIRiorakpDK7hS4SpzEYOl4vCyKEIy3Anc44LpAw
G0ROW+ol5JntOc6Vs1gZ
=RWLk
-----END PGP SIGNATURE-----

--nextPart1390365.niZB4vpOmQ--
