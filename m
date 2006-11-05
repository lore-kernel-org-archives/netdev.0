From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/11] convert d80211 to a proper protocol
Date: Sun, 05 Nov 2006 18:05:06 +0100
Message-ID: <1162746306.24574.28.camel@johannes.berg>
References: <1162741174.24574.22.camel@johannes.berg>
	 <200611051754.34099.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-V3YC6aNLnfYE4YZlUm1y"
Cc: netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>, Jouni Malinen <jkm@devicescape.com>,
	Simon Barber <simon@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	David Kimdon <david.kimdon@devicescape.com>,
	James Ketrenos <jketreno@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:65156 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1161352AbWKERGk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Nov 2006 12:06:40 -0500
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200611051754.34099.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-V3YC6aNLnfYE4YZlUm1y
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,

> Previously the open() and stop() methods in ieee80211_hw had been
> deprecated and the driver should enable or disable the radio
> based on the add_interface and remove_interface() functions.
> Now that the driver should provide open() and stop() for the netdevice
> structure does this mean that these 2 methods are back in control
> for enabling and disabling the radio?

Yeah, it'll have to, otherwise the device it created itself will be
totally useless unless some other device is also open.

> And if so what should the
> add_interface and remove_interface, should they be only in charge of
> triggering some configuration changes (like mode and mac address)?

Mostly notably it's probably going to be used for the drivers to have
veto powers, if they can't handle some specific combinations etc.

Though for 802.11h the radio does need to be turned off in some cases
regardless of the up/down state, so we'll have to think about that. Or
we just force all interfaces down? Not sure yet.

johannes

--=-V3YC6aNLnfYE4YZlUm1y
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARU4ZwKVg1VMiehFYAQLgzRAAwJ3Ao4VDydrZf2tDdLm86AHg8cC12iOI
JSb0Tl9OyVxDjNkPGWYdk9gxzIy8L28IhnqyiezRdUGLgs94L1Z8kwytCMr6wCRe
nE3HxpllbfZRHJ8/W6hBBJlkjx0QkeL5G05oMsCb42i572f6hD5FGREr7YV1hCDP
NcJprHGOQ6TTcluszY7/WbB8frGJXjePwFiAn/AvWAJjXOM9Qd3GEjcP6vFjZ+rs
+lKCpzI7kyPVew/BcnzzRS4IURXTbk8uFIMRGlA2+ogKtQiwKh3bUO1OK+PkRTw8
OW4r6iu7s7Rz6uIC7DhPf6We11tD4x5nFjvVH9Y549XH2B796joOYjUXo+ffD2yT
P9zFpbySo/U6Xc4QNa3BS0qORfGStURfTazXS1B2mNZccFnf/rdyS+0LdK3cNLGD
ukfOcHmm3golOQ6zRyQ0QhlMzBfykC3r5+9ap3TUUWj3G9YpuN+wDzry5B4g/T3a
7GJksYFXXn1eUesEUQF9TkJ6LX8xv2ZRzMhBNdrDGrwZ5XXk7WSr1ZcTfOioc3vR
84qc3vJc3AqDhVxQTXNBN8jMalTEGbE8HyNWewwIUZUjc9p8quJct/MYrLbTJ+NU
Qrj+nICoFxv/DgKzMc/QAN9veOWrZyBliw+xe6F2wGGla9M7QUOklKYZXds6tyoM
pIFYOYz6cRc=
=anzQ
-----END PGP SIGNATURE-----

--=-V3YC6aNLnfYE4YZlUm1y--

