From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: wireless vs. alignment requirements
Date: Sat, 24 Nov 2007 09:33:36 +0100
Message-ID: <1195893216.4149.186.camel@johannes.berg>
References: <E1IvoID-0006aR-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-0XAaGSeWkM1I0Kg8cO5b"
Cc: dsd@gentoo.org, davem@davemloft.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:44982 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847AbXKXIdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Nov 2007 03:33:51 -0500
In-Reply-To: <E1IvoID-0006aR-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-0XAaGSeWkM1I0Kg8cO5b
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > Now, the IP stack actually assumes that its header is four-byte aligned
> > (see comment at NET_IP_ALIGN, although it is not said explicitly that
> > the alignment requirement for an IP header is four) so that is actually
> > something for the hardware/firmware (!) to do, for example Broadcom
>=20
> Good point.  In fact IIRC we've always had the policy that drivers
> should do their best to generate aligned packets but it is not a
> requirement since on some platforms it's more important for the DMA
> to be aligned.

We still require four-byte alignment, no?

> So it's up the platform code to fix up any exceptions should they
> show up.
>=20
> Daniel, what's the specific case that you had in mind with this
> patch?

Well. This goes back to a user reporting unaligned accesses on sparc64.
Davem thought this came from the ether addr comparisons but the user
later reported that the patch from davem didn't fix it, and I think
Daniel just made a sweep over all ether addr comparisons replacing them
with unaligned ones.

johannes

--=-0XAaGSeWkM1I0Kg8cO5b
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR0fh36Vg1VMiehFYAQJb1w//dCIkxuDLflsOaMc/hf7ukqtjCyTSCc+r
BgFRwzT13aLoVhhZwi3+lDm7ISKMFyxmV8QlSZ1WZgOAeOCWrY6V5w4X4Mr1AmGp
wjiXq05eZ4xlDRLt/NFNzC7YY5gvufVu6xbK0B80jiXsH9LoRSkZgF6laTVn/sEA
+2wBMVLyxx0GFQRi7XzCHmfxNEulUS+5AjmuIOL0XFqqdDhTWsW/A811V02OR6lS
Z/AihNVV3supaZzNbkO1xD/8XBOo59Te345pKq1u/APiIog8Cti2lgUeR7ICJdZ3
Cm80MM8SW89eKsA9WHSs7DN0PaFQTBVozrMSWIA1xRZyJAWU815aNGi4e5G2yVwA
ondGkX2tztK0dXpOxmc5u8Xap1hcS0VE3gUj19kyzIMo7iuolCEZhXvKmjDHL+AI
wxW5s5lfL07WEbatNyDGx2tLg7cQf57ipvUEELrjef8vHH8AqH0BjbK2pRBDaA85
WUOJAEP8Zu39ob8/Ajw/AzpnxapcIQJhLEpgzNEOB4Xp0n+EMujc+hqxHGDvQQVP
SvYbEvp5Iea8v4y6hyc4jg/tvpCs/quXVld7lld38I+xc1GCDNwbdQTBZyf+Y64D
bKM84mnTbdzhAj2gyYdVuLmlUo68r+RdSiayxsjxjBeDtw/Ehay08niJOonOctF+
DdWDIaxjCbM=
=kM0E
-----END PGP SIGNATURE-----

--=-0XAaGSeWkM1I0Kg8cO5b--

