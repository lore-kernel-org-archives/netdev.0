From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip xfrm: support 64bit kernel and 32bit
 userspace
Date: Sun, 30 Nov 2014 09:42:48 -0800
Message-ID: <20141130094248.1fbc81a4@urahara>
References: <1417157936-5522-1-git-send-email-roy.qing.li@gmail.com>
	<1417311202.7215.109.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/rTCILj++dH4INpWmYb4r5z2"; protocol="application/pgp-signature"
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:51555 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752370AbaK3Rm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2014 12:42:58 -0500
Received: by mail-pa0-f46.google.com with SMTP id lj1so9511783pab.19
        for <netdev@vger.kernel.org>; Sun, 30 Nov 2014 09:42:58 -0800 (PST)
In-Reply-To: <1417311202.7215.109.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/rTCILj++dH4INpWmYb4r5z2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 30 Nov 2014 01:33:22 +0000
Ben Hutchings <ben@decadent.org.uk> wrote:

> On Fri, 2014-11-28 at 14:58 +0800, roy.qing.li@gmail.com wrote:
> > From: Li RongQing <roy.qing.li@gmail.com>=20
> >=20
> > The size of struct xfrm_userpolicy_info is 168 bytes for 64bit kernel, =
and
> > 164 bytes for 32bit userspace because of the different alignment.
>=20
> I think it's specific to x86 as other architectures have the same type
> alignments for 32- and 64-bit variants.
>=20
> > and lead to "ip xfrm" be unable to work.
> >=20
> > add a pad in struct xfrm_userpolicy_info, and enable it by set
> > KERNEL_64_USERSPACE_32 to y
> [...]
>=20
> This doesn't make sense.  32-bit compat needs to work like 32-bit native
> - no exceptions, no workarounds in userland.  And if you really want to
> work around this in userland you'll need a run-time, not compile-time,
> check.

I agree with Ben, this is not a good solution.
It creates a 3rd ABI (32, 64, and 32/64).

--Sig_/rTCILj++dH4INpWmYb4r5z2
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUe1cYAAoJEICnf2CVzeR+F5UP+QHm+0ozekO2XuR5MWYKlsiz
xJBboCqMVqKdD85I1KuKe9t/DWNVxskopN4sKOBcUuDfxTLN/ChexmEwWaNXFpPv
wNgNwEI35/6cB7d4VOFS/vZmweT6PTwimreA53MlkdH6qRzZzXYvuoj7vtXY7Xra
pj1vRZ3cns/ar6Tu6e5UBoC93yYXniM7MlhcFGyl/X8mvLPiCGIigmXL/5hgmNO2
YRgcz2URanzR3H5rmCZLoy5TbM6LUKSrfsPiDRgrTnUX+vzax89Jn5vfjT92dpoz
zTYfVBeP2PvClkbjAoEUzodFD9YDu/hCYfji/IuXNFcve7XRdhuGyNBIKFs4eqPn
Obp5wE/36mu3bT0ab7QCRiNnepWk/E65RCr9dFa5qXx8aC18tmMaFnK6aUw/ccv9
x1PSJPnYQDzc8e4GNqOhatvc8UqoR2O9S7bP0cW8XpP4wkVSlzwcFSk31Nq73MEq
p9gVsERSs8Yq6FXOv4sXuqWRA/07ENJ1BYDzpyLfQncsCwt3NZY2L0vc7/iRsI5G
xope2AzsWOA5bO0HDpgjRNKSEAgQn3M0zbHHOX7XdN6wExcT9CYONRv0AmekAEuY
aZBYrIPSZKUa0MLDDCJ9cf3L8uFtIf9UtyVt0UKC+7KvY/0NV0Coebr5e26jMeLr
RwaXAXbCUiCcYzuSYUW0
=BU7/
-----END PGP SIGNATURE-----

--Sig_/rTCILj++dH4INpWmYb4r5z2--
