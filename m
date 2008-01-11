From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: handing cloned frames to netif_rx()?
Date: Fri, 11 Jan 2008 23:58:05 +0100
Message-ID: <1200092285.3528.5.camel@johannes.berg>
References: <E1JDSPG-0008Of-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Yn/WtPvleIHPA8AvKlNi"
Cc: netdev@vger.kernel.org, ron.rindjunsky@intel.com,
	linux-wireless@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:58491 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761910AbYAKW6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 17:58:24 -0500
In-Reply-To: <E1JDSPG-0008Of-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Yn/WtPvleIHPA8AvKlNi
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Sat, 2008-01-12 at 09:31 +1100, Herbert Xu wrote:
> Johannes Berg <johannes@sipsolutions.net> wrote:
> >
> > Is it ok to do this? Will something freak out if we pass a cloned skb t=
o
> > netif_rx()?
>=20
> Sounds OK as long as you stick to the rules of cloned skb's, e.g., not
> writing to them unless you've copied it.

Ok. Yes, we will of course adhere to that, but I was wondering whether
maybe the net stack assumes somewhere that a packet it got from the
driver can be written to w/o copying.

johannes

--=-Yn/WtPvleIHPA8AvKlNi
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR4f0e6Vg1VMiehFYAQJWjg/8CnYI616TIYhuaUvZSim2EJTG3ucufT8Q
3ykFGabqdJsa2nI6aasPyJ0wFu95qslhHMiyT3hA1bYtWhg9aL/SlyD+my+o4Fem
3UcZ2gI9BbwGYJlKgdLSmd5NQ4yj/S6w5eqdYE4Vdzzl4w/xfW/iJUHRqvFYYgAm
7hte9vZPBE0xO8n+T3mP4sJaexEpqTeMSuY4PIO44rtqBmYDBWveQ8A7+G+jbAfW
7jwxqb3zIkOodaBAUZXxP60GiQ0DWrYcwtj7D2qJEbtZaeoGqc7muy5g+k9vHhM6
ImnwNKnB2NdngHTcp+K5q4bEgjEAEK8xit0OcQaMWWH/cokmIBz650yzIf1Zfi+y
lbuLMOzoBZERtzQ+UgWta/PAlVP+N+4lX9BQ9EkUBAvwrvRIVf2klQ8DggDQD4Vp
KxJW3nj4wqtg+z5Nm9dgS4hKaYEaQ8C0E/IYn2aZQ9/1np9StSl0obcP01v+Z9Rh
k9hu+bFQ8zf4Iv+lcY4Qdgoqm0qwKAsY+sN+/sO1LnV0SS8Q6yOb1LzAeesAZqmr
RGjWXpMDlRvStn7evBIHRwCUPjo3YOiADPz/X8N6MxlpCoR6dQdAcK/iTSFHxoJ2
wLih4zZXmRLUlUtuXLjJ6lozjMsrTF9rtjBMqE7xots9Q+HaM1/xrWMtwLDIIQIH
Df+pYxPwCVY=
=DFvb
-----END PGP SIGNATURE-----

--=-Yn/WtPvleIHPA8AvKlNi--

