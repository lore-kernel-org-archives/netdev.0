From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 3/32] rt2x00: use pci_*_consistent for DMA mapping
Date: Fri, 28 Apr 2006 14:57:31 +0200
Message-ID: <200604281457.35460.IvDoorn@gmail.com>
References: <200604280002.52839.IvDoorn@gmail.com> <20060427221127.GA22135@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1848679.fY311vE2JL";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.185]:23977 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1030377AbWD1M41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 08:56:27 -0400
Received: by nproxy.gmail.com with SMTP id x30so1488147nfb
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 05:56:25 -0700 (PDT)
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060427221127.GA22135@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1848679.fY311vE2JL
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 28 April 2006 00:11, Christoph Hellwig wrote:
> On Fri, Apr 28, 2006 at 12:02:52AM +0200, Ivo van Doorn wrote:
> > From: Ivo van Doorn <IvDoorn@gmail.com>
> >=20
> > Instead of dma_*_coherent
> > use pci_*consistent functions.
>=20
> No point in doing that, quite reverse as you use the gfp_mask argument
> which is a (small) pessimation here.

Would it be recommended that I replace the usb_alloc_buffers in the
rt2570 driver with dma_*coherent?
This would get the dma rings allocation and freeing a bit more generic
between PCI and USB and could reduce some duplicate code between them.
But I am not sure if there is any major difference between the two.

--nextPart1848679.fY311vE2JL
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUhE/aqndE37Em0gRAgu/AKDPZfFcJKtdbY/GcVqTg8pfpvJstwCfdRSZ
su8daxRM6SG/51s9c3qddlQ=
=B8no
-----END PGP SIGNATURE-----

--nextPart1848679.fY311vE2JL--
