From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH 03/16] batman-adv: add bat_orig_print API function
Date: Wed, 23 Oct 2013 19:37:56 +0200
Message-ID: <20131023173756.GC2651@neomailbox.net>
References: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
 <1382544303-2694-4-git-send-email-antonio@meshcoding.com>
 <1382547630.22433.23.camel@joe-AO722>
 <20131023171810.GB2651@neomailbox.net>
 <1382549233.22433.33.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="MnLPg7ZWsaic7Fhd"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:17656 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316Ab3JWRik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 13:38:40 -0400
Content-Disposition: inline
In-Reply-To: <1382549233.22433.33.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--MnLPg7ZWsaic7Fhd
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 23, 2013 at 10:27:13AM -0700, Joe Perches wrote:
> On Wed, 2013-10-23 at 19:18 +0200, Antonio Quartulli wrote:
> > On Wed, Oct 23, 2013 at 10:00:30AM -0700, Joe Perches wrote:
> > > On Wed, 2013-10-23 at 18:04 +0200, Antonio Quartulli wrote:
> > > > Each routing protocol has its own metric and private
> > > > variables, therefore it is useful to introduce a new API
> > > > for originator information printing.
> > > >=20
> > > > This API needs to be implemented by each protocol in order
> > > > to provide its specific originator table output.
> > > []
> > > > +static void batadv_iv_ogm_orig_print(struct batadv_priv *bat_priv,
> > > > +				     struct seq_file *seq)
> > > []
> > > > +	seq_printf(seq, "  %-15s %s (%s/%i) %17s [%10s]: %20s ...\n",
> > > > +		   "Originator", "last-seen", "#", BATADV_TQ_MAX_VALUE,
> > > > +		   "Nexthop", "outgoingIF", "Potential nexthops");
> > >=20
> > > This header printf really doesn't add much with the formatting sizes.
> > > It's pretty obscure why some of these are sized and others not sized.
> > > For instance: %-15s doesn't refer to a mac address size.
> > > Perhaps it'd be better to just emit the fixed string just using
> > > BATADV_TO_MAX_VALUE.  It'd also be easier to find via grep.
> >=20
> > This string is printed out of a debugfs file and follows a format that =
we have
> > been using for long time (this patch is just moving this code from one =
point to
> > another).
>=20
> I saw.
>=20
> > I didn't get what you mean with BATADV_TO_MAX_VALUE (maybe you meant
> > BATADV_TQ_MAX_VALUE? but even in this case I don't get it).
>=20
> Yeah, TQ not TO.  Both look similar with squiggles
> underneath them when using spell checking.
>=20
> It's a #define, all the others are fixed strings.
>=20
> Anyway, using
> 	seq_printf(seq, "  Originator      last-seen (#/%d)           Nexthop [o=
utgoingIF]:   Potential nexthops ...\n",
> 		   BATADV_TQ_MAX_VALUE);
> is probably trivially smaller overall code size too.
>=20
> Your code, you decide...

Now I fully understand your point.

Honestly I agree with you, but this string is there since a while and I'd
like to get a feedback from the other guys before changing it.

If for David it is not a problem I'd like keep it like that and I'll discus=
s and
possibly add this change (this is not the only header in the code printed t=
his
way) later.

Thanks a lot for your feedback!

Cheers,

--=20
Antonio Quartulli

--MnLPg7ZWsaic7Fhd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSaAl0AAoJEADl0hg6qKeOZPQQAKbiSS9KN2wHYUqULPtojRLi
t03+Gjotcoh86NDlp/6SxCO5kFj3IEoMTNuSeqbbexy4JvWa1fpiPAvhaYBeWMno
zVS/XzDAHPr0NhUABh01bVoc4+Q996yrQTBikQu7WWRsnVdOYfwwzIRpiZcIu0aL
ZtigN7hBZl8v2tTDWvpd8y1Q/H9Nf3i5XYqyiqm1qx3GDDinMSzDC4gjEI+8VDDj
f31p0iugfE/p8bGOy2gP0DO5fgVQE3gDCWFzdXbZgHKvQr4oHhtK0U3GdYIKkE0s
KYtnLJGuzTgvB6fcaLCdHaHgjTaMh7LtNKOhIZe+h8wukcZrvh2aFaVGKUce+X7A
MYdtWmX2Gy8WhZDYN4a1/BMhouV2Q1CzTN+Vx5mmUDwEc5okTYMpMugJiUJDjLeh
eNa2Dg3ugH/2Du+NUrJoHdCIkPlps1uOpP99NvQTMugPArGlkxY1cSoAb9qIdTgT
JArznljAe2vuVURGrUiugs4+4kBFHSKPlqkkePhAf6JzK5ujoiRrD1w28O3SKJcN
S9/5lkzA4wsIg/oGMSgN9Vg+Uv4YDhIRouWRVv3MBLZN4sGuB94/fvMQNFOTTwgX
k8UhLn+dT69yke1P3VB8ocmkQU0akFXZHqIk4D2jYGGBTClcpBPP1TWFPVZxdBCi
vEmYt1sBRuKGGRZnQvvk
=rgIp
-----END PGP SIGNATURE-----

--MnLPg7ZWsaic7Fhd--
