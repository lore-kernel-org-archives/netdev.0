From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Fri, 14 Dec 2007 13:37:40 +0100
Message-ID: <1197635860.16079.51.camel@johannes.berg>
References: <200712140002.lBE02aGO025491@imap1.linux-foundation.org>
	 <E1J35d6-00041l-00@gondolin.me.apana.org.au>
	 <20071214002209.ac748206.akpm@linux-foundation.org>
	 (sfid-20071214_082332_564160_804B85BA)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-JhBMBEYIia/6/k0H8Hyd"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:54925 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751659AbXLNMh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 07:37:56 -0500
In-Reply-To: <20071214002209.ac748206.akpm@linux-foundation.org> (sfid-20071214_082332_564160_804B85BA)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-JhBMBEYIia/6/k0H8Hyd
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> I don't see how it could warn about that.  Nor should it - one might want
> to check that rtnl_lock is held inside preempt_disable() or spin_lock or
> whatever.

I agree with this. IIRC I removed some ASSERT_RTNL()s in the wireless
code (or maybe it was only during testing patches) where we had a
function that required only the rtnl to be held but in certain contexts
was called from within an RCU section.

johannes

--=-JhBMBEYIia/6/k0H8Hyd
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR2J5E6Vg1VMiehFYAQKpIQ/9GGMpF84edT++nhteJxgrxRS7/svtgq3P
78EehyJDimrhtC/bH43NtzGE9NMI3NpT7B3aqs8H6uxvebmDNXxJ8mfmt4EjPZKZ
7/3Zj7nk7rswapu8a/ODwZ9bVydMvm3TL3hvDfw8a6fNmsUq8ETmM+4JJjAAgoz8
y5rorq2vQNHElcUNFpsHuiVz79W9w6C0ivJajLXTkUtHrtEwDxfpt8ncv0Tuqmiy
7vl1kGj5wQsbxx3aWrOL33zt6aTsrAov0enCGxIqYSSZXpr0Yy5IK+05Czw4H52b
QQOb8K3B/KKuuiowO3XtzeFGJb/nBReOWbTEAmytk+R/UfSoVWEzcXh4fIMQV2Fa
9DcOMU2UgHmhv6OjtNGhhkzUItLUAw0+jsIcPvNfHGoK4mHfYLNGzqX4/iNmkyvD
pPbxb8tucWLTeQm0Nf36OHtgwu7FgkeP/kgNwPuI9zJNG1IGTeJ8E84+fhPjRQKh
r2U2iWAxNZuBABFz0rhZiFElIdJcsJAl+8yXMi0KpOBrmnHfywOP9FYDEWOyE6a/
6lyhdsT3VfsXLYeYYDFJGOy+kDHW0q4MtGhhQoWi36gKsDcDeHcBiWWlVHD72E88
2vU9VePQebBUf0ZU02VhC+Bfi6qHlWAjvIGunYG9QlZuwwz9RzLc6KWq7nVgIvbF
3HYbQmkQaUo=
=GKA/
-----END PGP SIGNATURE-----

--=-JhBMBEYIia/6/k0H8Hyd--

