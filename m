From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 5/9 v2] net: Generalize checksum_init functions
Date: Sat, 26 Apr 2014 22:43:47 +0100
Message-ID: <1398548627.16049.8.camel@deadeye.wl.decadent.org.uk>
References: <alpine.DEB.2.02.1404261400430.26913@tomh.mtv.corp.google.com>
	 <1398548524.16049.6.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-P+h6we36xcERWSW6+PnO"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39355 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752390AbaDZVnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 17:43:51 -0400
In-Reply-To: <1398548524.16049.6.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-P+h6we36xcERWSW6+PnO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-04-26 at 22:42 +0100, Ben Hutchings wrote:
> On Sat, 2014-04-26 at 14:25 -0700, Tom Herbert wrote:
[...]
> > +/*
> > + * Perform checksum validate (init). Note that this is a macro since w=
e only
> > + * want to calculate the pseudo header which is an input function if n=
ecessary.
> > + * First we try to validate without any computation (checksum unnecess=
ary) and
> > + * then calculate based on checksum complete calling the function to c=
ompute
> > + * pseudo header.
> > + */
> > +#define __skb_checksum_validate(skb, proto, complete,                 =
 \
> > +                               zero_okay, check, compute_pseudo)      =
 \
> > +({                                                                    =
 \
> > +       __sum16 __ret =3D __skb_checksum_validate_unnecessary(skb,     =
   \
> > +                               zero_okay, check);                     =
 \
> > +       if (__ret)                                                     =
 \
> > +               __ret =3D __skb_checksum_validate_complete(skb,        =
   \
> > +                               complete, compute_pseudo(skb, proto)); =
 \
> > +       __ret;                                                         =
 \
> > +})
>=20
> This may or may not yield an actual checksum, which is not obvious from
> the comment.
[...]

Sorry, this is incorrect; it does yield an actual checksum.

Ben.

--=20
Ben Hutchings
The most exhausting thing in life is being insincere. - Anne Morrow Lindber=
g

--=-P+h6we36xcERWSW6+PnO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1wok+e/yOyVhhEJAQoa0xAAtgD/0QZhB7tv7hd++G2z6VgzR6QtKUhp
c8UQJ/7bht3YxvC1Db7N7LSJiFsSnRY0bYwRVZJbo46cZXmxWBFPWeBg1VbowjzQ
WHq5kv6Boft/qQQtQ53VcPw5hn6ZAqNEaTJ5OWWzlVfiOxhuOLxVmQsdZTo0FWfP
T4UfshBrMoppR1EEL2z6uR1E9w5zAVkjFvsDME+zaOiCWFYn4NrMK7J/a9H0aMxG
jROnOGrnMI1QtbjW6ajtYJllv4jvdwRllrl4OoXUBdSveVxH5wpQzvjRGStHqMlJ
hYOav2DcmD8Dt8TyLOSDlUYYwbhUyKtkoaudk41XR2g20lz+r/GCRQSrcNYFmj6i
7aJ58T0OwKDLmc2RRDIBIx+u5WHatl+8UjpBMdOybM0m0DBQVs4xSqQS1eS7LuCh
e6VGeI46jawCQM1MKmn15h0HTFDtVm6wDZSCBhl6hnW6b4TLE7XpBn2uimjhT0XA
WKxvb3/TlURwYN8/mulNF8+8VZUahBy4+n/rwDx8IVgEwuIKOMzZcRvu3yYo8Exf
j9tZPBtlPf72PcUw1Jz0u7sZpM327pEgm+YH40bveX+LFbTmOIxHSoTRomW1cw4+
2Y004MrRNHLAp+iUZB0gvbSRdHLYNw63GcI+zGuYk8pn92dv/8G0plyw+JlJrN72
V6Kes98lYSw=
=i7I6
-----END PGP SIGNATURE-----

--=-P+h6we36xcERWSW6+PnO--
