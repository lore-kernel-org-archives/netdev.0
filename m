From: Ben Hutchings <ben@decadent.org.uk>
Subject: [stable] tcp: drop SYN+FIN messages
Date: Fri, 13 Jul 2012 02:46:18 +0100
Message-ID: <1342143978.25597.376.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ISexo6SMMVH/VuYIIaCM"
Cc: netdev <netdev@vger.kernel.org>, stable@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:44306 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932250Ab2GMBq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 21:46:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ISexo6SMMVH/VuYIIaCM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

It looks like this is needed in 3.0.y and 3.2.y:

commit fdf5af0daf8019cec2396cdef8fb042d80fe71fa
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Fri Dec 2 23:41:42 2011 +0000

    tcp: drop SYN+FIN messages

Ben.

--=20
Ben Hutchings
The generation of random numbers is too important to be left to chance.
                                                            - Robert Coveyo=
u

--=-ISexo6SMMVH/VuYIIaCM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT/996ue/yOyVhhEJAQqL9Q/8DH2ICRS1WNPosR+ojpapAWNlu/T8kS/m
lKeJrAILZdqbohmc4vassPit8N3y18+MLIrYhBHnu7IzkmIpz6P7aW+dVsWx5pgc
sa2MhW9aIPBF23EfrZJ6ykdCcjFn/mA5FR6e09aCWCgGjlY7VVVydQEtlwW7sAQu
JG+PKEpPThL4iZfKRdAaOw/fifirHxdK3Tl8A+BEXgv09gRkys78H3EOQvLGWLub
7DOnpz3MLuQaBZ9BNmDoBk6LlQUD93Wol/iCrh4UC5IqSXgfz3hDvALH89Ng65CW
mH6cNk75z/dGGdcfLBJHUvOpeDAMsrsmIJlozwF80g5giO4/v3aFwIBo0qZpwHLS
DnCMIEUCw2omIRYtsuGcnvWVPnYz8G5lpnJ9S7p4eZuehYgEjTAoBeI3WPaRz//b
fsSOKgFbogbhbaaqK9Vb5t37GhqDcGMU81QxwB+7twlLkBPLjiGcRvTokdhoxN6o
9ZIXWF20uSjL6z6t1inje/rDIulo/I3yXqOL7mOKyWAmyuSxQySlCbrsZ5V6eNQP
d8zIdGHCy/Ju4dJw9LZPi2w+SsyDRPPfqxrV1Ts5YjKlXQjlCc01NOtQ7wcBAo5h
+/b5kQCePsVj9Z9uHTrDtRznGVCirsy9f7B9s6FI2QYvFvoO4gfzf8frkA9yu8HL
yVss5umyk5g=
=c28u
-----END PGP SIGNATURE-----

--=-ISexo6SMMVH/VuYIIaCM--
