From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 20/32] rt2x00: byte ordering correctness
Date: Fri, 28 Apr 2006 17:01:32 +0200
Message-ID: <200604281701.33512.IvDoorn@gmail.com>
References: <200604280003.12743.IvDoorn@gmail.com> <200604281542.29534.mb@bu3sch.de> <20060428134632.GA4526@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3865250.pgA6czVHLs";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.189]:34295 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1030425AbWD1PAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 11:00:24 -0400
Received: by nproxy.gmail.com with SMTP id n29so1596267nfc
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 08:00:23 -0700 (PDT)
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060428134632.GA4526@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3865250.pgA6czVHLs
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 28 April 2006 15:46, Christoph Hellwig wrote:
> On Fri, Apr 28, 2006 at 03:42:29PM +0200, Michael Buesch wrote:
> > I guess you are confusing something here:
> > MMIO access versus values in structs (for example) that=20
> > are accessed through DMA (for example).
>=20
> so there's two general problems:
>=20
>   mmio/pio   - linux expects the device to be le there by defalt and
>                {read,write}{b,s,l} do the switch automatically
>   dmaed data - you always need to switch data yourself, data is commonly
>   	       either be or le
>=20
> now there's devices that are always be for mmio or can be switched to it
> during initialization.  For Linux you'd traditionally have to switch befo=
re
> calling {read,write}{b,s,l} or use the __raw_ version that have other iss=
ues.
> The ioread*/iowrite* APIs now have a BE version, too.

Unless I am mistaken, or the ralink design sheets are outdated on that issu=
e,
I do recall that there was a big endian switch in one of the registers.
I think I need to definately investigate that to see if it would be usefull=
=2E :)

Thanks,

Ivo

--nextPart3865250.pgA6czVHLs
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUi5NaqndE37Em0gRAlnXAJ0SjBLp5RQ5hu30yWABmkMY1dN47ACgnYXb
EpishO08jAFo+LbUKMLbv00=
=Hhhg
-----END PGP SIGNATURE-----

--nextPart3865250.pgA6czVHLs--
