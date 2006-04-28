From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 20/32] rt2x00: byte ordering correctness
Date: Fri, 28 Apr 2006 15:56:30 +0200
Message-ID: <200604281556.30917.mb@bu3sch.de>
References: <200604280003.12743.IvDoorn@gmail.com> <200604281542.29534.mb@bu3sch.de> <20060428134632.GA4526@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1390429.HPcBLrd6CS";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ivo van Doorn <ivdoorn@gmail.com>, netdev@vger.kernel.org,
	rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:50333
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1030403AbWD1NvL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 09:51:11 -0400
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060428134632.GA4526@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1390429.HPcBLrd6CS
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 28 April 2006 15:46, you wrote:
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
>=20
> I've not heard about devices having this switch for dma payload, and it
> would be rather usual as large parts of it are determined by some on the
> wire protocol anyway.

bcm43xx has a switch for this in PIO mode.
But we are currently not using it, because it is a little
bit tricky to get right and I did not want to do such experiments
before 2.6.17.

=2D-=20
Greetings Michael.

--nextPart1390429.HPcBLrd6CS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBEUh8Olb09HEdWDKgRAoE6AJ900aeIHb3KjNkV5k+hGy6qbEPFDgCbB0AO
HOACTmIvwfNo1WAE+yf7tnM=
=iKY0
-----END PGP SIGNATURE-----

--nextPart1390429.HPcBLrd6CS--
