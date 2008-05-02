From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: mac80211 truesize bugs
Date: Fri, 02 May 2008 22:38:51 +0200
Message-ID: <1209760731.3608.17.camel@johannes.berg>
References: <20080501.024320.212547875.davem@davemloft.net>
	 <E1JrW9h-0001tI-00@gondolin.me.apana.org.au>
	 <20080501.034950.261408566.davem@davemloft.net>
	 <20080501.035335.216935614.davem@davemloft.net>
	 <1209639500.7067.0.camel@johannes.berg>
	 <20080501110341.GD7490@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Hg89H5KeH/uf4gDPMjoh"
Cc: David Miller <davem@davemloft.net>, mb@bu3sch.de,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:41391 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936202AbYEBUjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 16:39:07 -0400
In-Reply-To: <20080501110341.GD7490@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Hg89H5KeH/uf4gDPMjoh
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-05-01 at 19:03 +0800, Herbert Xu wrote:
> On Thu, May 01, 2008 at 12:58:20PM +0200, Johannes Berg wrote:
> >
> > Indeed. But then why did we never see this bug w/o monitor interfaces
> > and this reinjection?
>=20
> The debugging only catches it if the expanded area actually
> gets used, e.g., by skb_push.

I'm confused. The area should be used say with encryption when it's
actually necessary. Maybe there's always enough headroom for some reason
now?

On another note, why is this truesize mismatch a bug anyway? I mean, the
field could just be called "socket_charged_size" and simply be required
to have the same value throughout the skb lifetime, the slight mismatch
between charged bytes and actually used bytes wouldn't usually matter
too much, would it?

johannes

--=-Hg89H5KeH/uf4gDPMjoh
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASBt72qVg1VMiehFYAQLHog/+I7ITJvJY7grEcWMS0sVXaVCUwDcnYA6Y
F5ak4qifw9SEpeFV2Mjg8tqUDt1qD9mGN4B7koJMPTfm0gXbsLYgJYI8No3M+noY
wS2146Fj3z7tbivDUqe8ZIU2LPja+NdOe6jR63scaE1xbImV5QLqIwItG2tGG3Bb
W/VgR+i9X9jIHOFl5WMAefruGopcU6q2eE6hFCpXEqrAHR3070HeiEsaoa+imbgr
Pvq+c6Zkn3mFbX4u9NKc8wZCiMNc0TExYrlbS32huZ/CEGFdaBc2ICwZAgdDyjf0
WY/bH57QZXVKwSgWTWk6Umy7uXNXcbuONQL/YJork8JxebsgRqm/3Xu1VIHZE9lo
eJ22hpeBZtPDH7oY4DwGnKqgyp69561ApP+SLuSzLFFsQ8fH5lqN1VkaaTtkvRBe
pMZKOY2sTqiNUg3tEWsduz6P1/ThzN/Mpgiwi0GknUnlxv/L9NqOMquR7BB9o8VE
b36SdCVqv4Eq7OHo1JCqEeJz7eL1H0aDdYJnv5A8RNmQlb7T91URoHJYtinhv6Ui
+1EGpu6L1j5nL9S6Lze6i5Oa8fXH+acuN7Ero1ecj8TV9zwq4ECQVqi2SdmAAA0z
Qv3bphktlUMD0YoajAbyrRta+VIhIM5PTbSwKp7J/8aCAJ0lMM0LwG6fdj9nCZmq
gixW5xYa7ls=
=4v8D
-----END PGP SIGNATURE-----

--=-Hg89H5KeH/uf4gDPMjoh--

