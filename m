From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v4 00/11] add support for new
 ETHTOOL_xLINKSETTINGS ioctls
Date: Mon, 14 Mar 2016 00:27:43 +0000
Message-ID: <1457915263.3331.58.camel@decadent.org.uk>
References: <1457719104-39188-1-git-send-email-ddecotig@gmail.com>
	 <1457890220.3331.41.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-SGM2pXDwh9M0ARcT2lsP"
Cc: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:42381 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932298AbcCNA1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 20:27:51 -0400
In-Reply-To: <1457890220.3331.41.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SGM2pXDwh9M0ARcT2lsP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2016-03-13 at 17:30 +0000, Ben Hutchings wrote:
[...]
> Patch 11: you need to answer my question about this.

[This is about why/whether there should be a fallback from creating an
AF_INET socket to issue SIOCETHTOOL on.]

I looked a little further, and found:
- The only address/protocol family that is always present in the kernel
=C2=A0 (assuming CONFIG_NET=3Dy) is netlink
- Netlink sockets don't support ioctl at all

So there seems to be no right answer to 'which family of socket should
I create to perform device ioctls'.=C2=A0=C2=A0There really ought to be!

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-SGM2pXDwh9M0ARcT2lsP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW5gV/AAoJEOe/yOyVhhEJg5oQAJ+8iPDZmbiZDCPQWUT563fR
o08lH/48oNVXlIrdfOfq1crrSIakQGGYf3lvl6gm2GBFiRxKe5VnYgAVc404bxHM
VgVtt3zz2e0TJCsAQTc+IoVjSo14tD7hH2Fv46wwU3fAk8I2JwU+TnjCihSh+Ga0
vI4GI/IUhp1guHMWFCuhtkyGD1QAolN2Hc3yuQrG3ykV4+E+3F2zT+n83J4WUMXP
kBCsh42u1PO+v3VI+pPZ/rxl2PtVlHdB5x+0CpjlUkm0eo3Y0LyMHoJeNApuwzt7
ygpRRwb0/EaZb4LYGONXap/tNtwKT+HR0hFHcc9xZIg/rbI8F2rJ3YBsYB32qEqa
Cuxjsju7f1gqimBw/SNJnwYI7KZsmzlvn6cCatEHN7hwKQxy3bT5JxN3bwdzS3Fs
K41rzI2qHva/rx0oPSiqDcSN+/WhUblB3Dl1exkPqYx4Ach09R0Ld7LsLvCR8K1y
2oRAycYUoFHdWU9tXDjHd/IHaQ7BEMAcJBN67Kptb+8gU7Ww42lppwJgUFRSgx2d
46wqLUvsUU/UOE0qi2IhnN5CX4MeIuv7cUsMXm2OeloOEHQjHoz/wqrkfKjtHKKS
tNr8t8yS6d7CAs9o3nRl3hcNn69/t7uCxQje7YqU92KRunF5stml5dRwok+EPha3
t1nMOGCrZ2VcCW8vNnPf
=++07
-----END PGP SIGNATURE-----

--=-SGM2pXDwh9M0ARcT2lsP--
