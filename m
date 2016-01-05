From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH stable-3.2 stable-3.12] net: fix checksum check in
 skb_copy_and_csum_datagram_iovec()
Date: Tue, 05 Jan 2016 16:40:08 +0000
Message-ID: <1452012008.2768.82.camel@decadent.org.uk>
References: <20151228140157.6F592A0C7D@unicorn.suse.cz>
	 <568BF0FD.4010208@suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-jLeIei/M+6SYdUs8AYdn"
Cc: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org
To: Jiri Slaby <jslaby@suse.cz>, Michal Kubecek <mkubecek@suse.cz>,
	stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51929 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751631AbcAEQkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 11:40:22 -0500
In-Reply-To: <568BF0FD.4010208@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jLeIei/M+6SYdUs8AYdn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-01-05 at 17:36 +0100, Jiri Slaby wrote:
> On 12/28/2015, 03:01 PM, Michal Kubecek wrote:
> > Recent fix "net: add length argument to
> > skb_copy_and_csum_datagram_iovec" added to some pre-3.19 stable
> > branches, namely
> >=20
> > =C2=A0 stable-3.2.y: commit 127500d724f8
> > =C2=A0 stable-3.12.y: commit 3e1ac3aafbd0
>=20
> Applied this fix to 3.12. Thanks!
[...]

You don't want this, you want Eric's fix (commit 197c949e7, "udp:
properly support MSG_PEEK with truncated buffers") although that's not
upstream yet.

Ben.

--=20
Ben Hutchings
Tomorrow will be cancelled due to lack of interest.
--=-jLeIei/M+6SYdUs8AYdn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVovx6Oe/yOyVhhEJAQrAiA//f3/5QTT6hjjtY3pgFNMrHbrMYrFRkFHq
e11iXoNc+aEFw0yWnB1g+Re10ZM3vroLWC/cZqncviZB22mPM9CH7RsUc6rPjCou
eN84M2SSpx4K2TGVoWPDpUHB86Op3w1OVuwndcCV1OBl6JSlzemNboFg1CF/v1ll
GddrRmSfxTZ1XYJzOiwtG+qwm3bKYI5vMSspIZvqS341r72Z6MANwmLzNACuI++b
6nSgItTWier+Yvuhuzv1WHkDFWMX5n9bWUSnPsBmVY/M543jQ4kZaYmOocUIWgLg
tPCn+X3PP6EgnIELpb3vTPSItBTKJZCPRUUO2QUadz23ZVRS4MlcbC/NoJEAfHwB
AO0bj5lc91oPyvuK6V8m1VhBHMW2HCi79NFBtMzZwLCee/HJ4nXo4uFuHeL6CMTE
s104JuLZK4HOEeP3u5h/RQfKoFX00gfLBiYYKlngUAieN73QiWpYQTJZSZSpekJT
u7ltOzJHRgW4VwEM80ih8dzEGeBthtfBO7QK/7QiJyeM/GPTm3VRdiIXAgLTGmvj
8oeG4M1iUtxKApYg6OyhMM63HcULeiIYER7S04YpZJsZV7uP9SIFnFcV7R8uo/l3
Y9ESxRhZP3mnl03D2u3RXrzCDFCjIvs9AqmdsOqpnbvXPk2fCW9U9W3H5N0/aV1j
nmyHDQ6kVss=
=scDr
-----END PGP SIGNATURE-----

--=-jLeIei/M+6SYdUs8AYdn--
