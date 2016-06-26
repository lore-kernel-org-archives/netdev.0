From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v1 2/2] ethtool:QSFP Plus/QSFP28 Diagnostics
 Information Support
Date: Mon, 27 Jun 2016 00:06:18 +0200
Message-ID: <1466978778.2551.28.camel@decadent.org.uk>
References: <1465860426-30387-3-git-send-email-vidya@cumulusnetworks.com>
	 <1466933589.2504.42.camel@decadent.org.uk>
	 <CAKWE-XqgZ0hnqfLddg+ui4kTwZXzqKjq9vaXPod7fn=wBxByBQ@mail.gmail.com>
	 <1466978549.2551.27.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-pCj65j9pYz/eM2YAQ69p"
Cc: netdev@vger.kernel.org, bwh@kernel.org,
	David Miller <davem@davemloft.net>, bkenward@solarflare.com,
	daniel@iogearbox.net, Gal Pressman <galp@mellanox.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Dustin Byford <dustin@cumulusnetworks.com>
To: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60380 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751459AbcFZWGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 18:06:22 -0400
In-Reply-To: <1466978549.2551.27.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-pCj65j9pYz/eM2YAQ69p
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-06-27 at 00:02 +0200, Ben Hutchings wrote:
> On Sun, 2016-06-26 at 09:40 -0700, Vidya Sagar Ravipati wrote:
> > On Sun, Jun 26, 2016 at 2:33 AM, Ben Hutchings <ben@decadent.org.uk> wr=
ote:
> [...]
> > > This looks very similar to sff8472_diags, only with the actual values
> > > separated from the arrays of thresholds.
> > >=20
> > > Can the structure and code be combined with sfpdiag.c, with the
> > > additional per-channel diagnostics being optional?
> >=20
> > Diagnostic dom information in QSFP=C2=A0=C2=A0has lot more information =
compared
> > to SFPs and as part of this checkin , basic dom information in qsfp whi=
ch is
> > equivalent to sfp dom=C2=A0=C2=A0is getting exposed as part of this che=
ckin.
> >=20
> > Here are list of fields (not complete)=C2=A0=C2=A0which=C2=A0=C2=A0are =
used for=C2=A0=C2=A0debugging QSFP
> > issues, will be added for this structure in next patch sets
> > a) TX/RX output amplitude conttrol
> > b)=C2=A0=C2=A0TX_DISABLE
> > b) TX_FAULT
> > c) TX CDR
> > d) RX CDR
> > e) RX output disable
> > f) Rate select option
> >=20
> > Please let me know if it make sense to maintain the different structure
> > with above explanation=C2=A0=C2=A0or whether it is required to be combi=
ned.
> [...]
>=20
> I think there's enough information in common that it does make sense to
> use common reporting functions, and that in turn suggests that it would
> make sense to use a common structure. =C2=A0You could alternately have th=
e
> callers in sfpdiag.c and qsfp.c extract the relevant fields and pass
> them into the reporting functions.
>=20
> The substantial duplication of reporting code from sfpid.c in your
> latest submission is not OK.

I mean sfpdiag.c here. =C2=A0I didn't check for duplication from sfpid.c,
but I think you've avoided that.

Ben.

--=20

Ben Hutchings
Humour is the best antidote to reality.

--=-pCj65j9pYz/eM2YAQ69p
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXcFHaAAoJEOe/yOyVhhEJz3YP/0uJe2KRswAQiXS40P1PFO0U
h27E68ojsYxDEqE2FRljogPjU/ko+Y0NRvnz3qTmJQFS5xeI8QA2BiVo/XQs3amD
gpjSHZ/Z9n9F5zwWmoVxh8Gr09Zr/H1LHHhR/yo3E2Yq6ubHaa+SJ4DVJMHFFRXh
cMzEgVN9VtDEHgNl4fpXZcEOAWev261UFGtnJmVx2vV0Zysn6Ss9xwlFsu4l90nU
7J5gsGFJDBIqSapuN9J86+hCE8VgjSY/ATULTioWaql1jcvM/s10uPaeOwJB0drs
BzDG8aX7/dp85KZuMLBkWhe8h2Lx9EeQM48T3xAIlvbd3OYxHwqa69v6caedDd8T
YpcHTk86bSgcvIWfsccB7r1kynBxJBrABokfT4WMWifvbyGGswSuyYjukgYKpsx4
VSPlHKsqrz7vcbSWuRRSAi9kl2ncOzZlX2FgF2KIlLmxCoAtDo++czWZwf9Em56O
M3oT752UAhyI3zY1dbZpv005yw2C3Vd2ZjgRdSPVuYx2641LpZo0Av5keqURJMJW
Ey78ssUEF6u414OQH8taY4E+axomdmsPdfYzpQi4eZgNISlRSbYl3fWZAv5tb88m
SbHMelpCQwqxjkh98+01WW4l8Z59ojnCS2ggVd8FCBJy5wBL+J5paoTrXPiyyVq4
BBrwAjCqwD5i5UM8lV3L
=i1Yi
-----END PGP SIGNATURE-----

--=-pCj65j9pYz/eM2YAQ69p--
