From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Re:Re: How to set the filtering rules for drop the packets
Date: Tue, 22 Apr 2014 19:05:27 +0100
Message-ID: <1398189927.7767.83.camel@deadeye.wl.decadent.org.uk>
References: <35e52a86.138f1.14583b52f31.Coremail.mstian88@163.com>
	 <1398080944.3624.99.camel@deadeye.wl.decadent.org.uk>
	 <6a2bd57e.18e1d.14587cb4cea.Coremail.mstian88@163.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Okeynql7PvTV0oydWGmt"
Cc: netdev@vger.kernel.org
To: mstian88 <mstian88@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53927 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933214AbaDVSFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 14:05:33 -0400
In-Reply-To: <6a2bd57e.18e1d.14587cb4cea.Coremail.mstian88@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Okeynql7PvTV0oydWGmt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-04-22 at 12:56 +0800, mstian88 wrote:
> thanks for your reply ,=20
>=20
>  my NIC is intel X540-T1, when i set dst-port filter first ,suceess,
> but then set src-port filter failed=E3=80=82
>=20
> That is to say the filter rule src-port and dis-port can't set
> together=E3=80=82

So you can insert either filter individually, but not both?  How odd.
You could ask the ixgbe maintainers whether this is a real hardware
limitation or a bug.

> There are any other ways to filter the packets that srcport is 80 or
> dstport is 80?

You can do it in software with netfilter/iptables.

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-Okeynql7PvTV0oydWGmt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1avZ+e/yOyVhhEJAQpz2w//d6ZeBF1zPzFY+mx2GjkGQm6WKPKYAyBx
JBQy6xlOdz51ZwGIm3HIDf8WDFzlVqLd2YA8wZ4GGZuYyXuw0MwqYqW5MI8RHfKT
epdWKoothwCzdjBF8vRxRDEYvtaALymanNUmkZRykCCjD1P2nB49Vr5bwDaHVIVp
m8WjyfHUfjPtSP5jyXhXLzcadEGhkcpdclhMdwNeoh6f5DHGnjXAakfC1nwRQWO7
77jtHysw7CiQ7a6zVMN/7bsxcbbvW4cXgSxy4IZxbYOF6JNYOURSxnaBQhrbNVn2
JfrgO1itPJPojtctbKMpwx0IFguWFliPFDCnOIhCXGkzeZNA80J4s0YmEuKt2jwu
mhiSWc/Uphb9zTe8GhQzI9I+XE3lEQYEGHr2NYSyqwk+qUUl8TtOL9ocd4TW/ZiF
AIKmOhkfLErkqPNF5S7bCliQvqn6oJtSqTetQBVVjF4tBLQzPJx8sXb6u+yD2zmE
L6fzfEYP7i96UeAHjNwJIqaCkPPFPmk/7ky3Ve2kmpMIpDKOJ3aFuQGS3fnIbodA
b04oUSqWyY6eE6ciQ5VldlI64oyvH/090YMFZxAgxaBJ1knzwDDqrbfCVS+HNcWM
mOW3TJwKueIA+yem+4hg2F3RjYH7NKN/0SgnldJp/AJF26k4ct/Tujdp428IyF7V
X8voJTi0Bsw=
=iP+x
-----END PGP SIGNATURE-----

--=-Okeynql7PvTV0oydWGmt--
