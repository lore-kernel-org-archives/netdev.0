From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [RFC PATCH net-next] ipv6: implement consistent hashing for equal-cost
 multipath routing
Date: Mon, 28 Nov 2016 21:58:49 +0100
Message-ID: <583C9A89.4060404@uclouvain.be>
References: <1480017556-25988-1-git-send-email-david.lebrun@uclouvain.be>       <20161128.112248.2198395724649783009.davem@davemloft.net>       <583C9093.7060404@uclouvain.be> <20161128.153209.2135257061368558724.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="1cbhBNE9h1knP9cK0QuvcWSxfiXbQFu2B"
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:49565 "EHLO
        smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754808AbcK1U6u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 15:58:50 -0500
In-Reply-To: <20161128.153209.2135257061368558724.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--1cbhBNE9h1knP9cK0QuvcWSxfiXbQFu2B
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 11/28/2016 09:32 PM, David Miller wrote:
> When I was working on the routing cache removal in ipv4 I compared
> using a stupid O(1) hash lookup of the FIB entries vs. the O(log n)
> fib_trie stuff actually in use.
>=20
> It did make a difference.
>=20
> This is a lookup that can be invoked 20 million times per second or
> more.
>=20
> Every cycle matters.
>=20
> We already have a lot of trouble getting under the cycle budget one
> has for routing at wire speed for very high link rates, please don't
> make it worse.

OK, so O(1) mandatory. I will continue in that direction then.

Thanks for the feedback

David


--1cbhBNE9h1knP9cK0QuvcWSxfiXbQFu2B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iEYEARECAAYFAlg8mowACgkQjbzn67sZ6AOf/gCeLyzaXsNlEqPeuEmAyIE6vRQU
JdgAnjEFhAdn5BZXTnZiHYVduOlt+9Nn
=nnvG
-----END PGP SIGNATURE-----

--1cbhBNE9h1knP9cK0QuvcWSxfiXbQFu2B--
