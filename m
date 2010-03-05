From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Re:[PATCH  kernel 2.6.32-rc5] pcnet_cs: add cis of PreMax
 PE-200 ethernet pcmcia card
Date: Fri, 05 Mar 2010 12:46:19 +0000
Message-ID: <1267793179.2819.328.camel@localhost>
References: <20091025111000.2d97e595.ken_kawasaki@spring.nifty.jp>
	 <1267747341.2819.177.camel@localhost>
	 <20100305202153.fb39cd64.ken_kawasaki@spring.nifty.jp>
	 <20100305210151.b27ce31a.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-oCLxROCFW/hbpMXj/cBr"
Cc: netdev@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>
To: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57222 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750745Ab0CEMq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 07:46:26 -0500
In-Reply-To: <20100305210151.b27ce31a.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-oCLxROCFW/hbpMXj/cBr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2010-03-05 at 21:01 +0900, Ken Kawasaki wrote:
> Hi,
> =20
> > The CIS files under firmware/ are, according to firmware/WHENCE,
> > 'developed by the pcmcia-cs project'.  So I had a look at what's left o=
f
> > the pcmcia-cs project and its last release, and found that it includes:
> >=20
> > - the tool 'pack_cis' which compiles a text version of CIS to the
> >   standard binary format
> > - text versions of most of the CIS files
> >=20
> > Since the text versions contain comments which are excluded from the
> > binary format, I believe they should be considered the 'preferred form
> > for modification' and included in the linux-2.6 and linux-firmware tree=
s
> > along with the binaries.
> >=20
> =20
> Actually, it is better to build CIS by "pack_cis firmware/cis/src/xxx.cis=
"
> instead of "IHEX firmware/cis/xxx.cis".
> =20
> In that case, the "pack_cis" tool should be included in the kernel-tree.

We don't include other firmware-building tools in the tree, even where
they are free software.  Why this one?

Ben.

--=20
Ben Hutchings
Q.  Which is the greater problem in the world today, ignorance or apathy?
A.  I don't know and I couldn't care less.

--=-oCLxROCFW/hbpMXj/cBr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS5D9Gue/yOyVhhEJAQJYFw//VOL4Kbmk8csZjEK4r9pWFPwIkfayugRW
EIhWJGMSgOlXzJkc8QW/SUicu+NYiIQy4N/5d+rkvlS3fnCyq5C8ueMLDE8yPnxT
1RF/93Zp60eRqNcw28S3kT8EJKwQsCF6pT0dZnRHVS6H9HGkYPkQNpYkV4UN3Zop
pw10nK3yD86d4vR5d3QHVsszRsiVjK9FwzqK3pF4JawLi5cgbzM2ua2QEXS6k14T
0sI5cgCn1WPrAvVzoAFFZ+R8XVRqh24IzvIwE+9+OA0vYdNpi6kmOqVLSQZBSKO5
35VFgIuSHUZqNdkaTDM9Fn9Lnue8Ld+YGAJeVF7cLktOsE5VGYDAWHPvsMJAkrXv
NSzLb79XidOF9tAKLpEqeTB9Ax3ccnzXsK0ksU/H+qOnD9YeGYP3+vi6MPYow81u
qEJUj1MNlIlHUktlXvReS1ROhtKUjznIlZu5plHAIIhXHOaxgGBe2DBS7GPeQ58A
eupi/ES9P5a8OyJAPRYppOCPwiYR8JX9o5jT7yIHg7x466QKK/Wzy4Vjo47JstEg
2k4MH9XnfteW51nQ9+qVtixmZ7KDBIqjwWFBzFth5kQjMD6C7wUAxAPKp7n1ToO4
2ZKDnwKb8jBQGSRaZeLA0KvaVGyrcsKsS6IWd/auTe8BMa3UduN4kwzDJF41FNnw
Szm9pDoeWLM=
=iJ8m
-----END PGP SIGNATURE-----

--=-oCLxROCFW/hbpMXj/cBr--
