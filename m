From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 20/32] rt2x00: byte ordering correctness
Date: Fri, 28 Apr 2006 14:59:23 +0200
Message-ID: <200604281459.24186.IvDoorn@gmail.com>
References: <200604280003.12743.IvDoorn@gmail.com> <20060427221321.GB22135@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1354372.gZZ9ach4Jz";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.187]:53677 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1030381AbWD1M6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 08:58:20 -0400
Received: by nproxy.gmail.com with SMTP id x30so1488439nfb
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 05:58:19 -0700 (PDT)
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060427221321.GB22135@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1354372.gZZ9ach4Jz
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 28 April 2006 00:13, Christoph Hellwig wrote:
> On Fri, Apr 28, 2006 at 12:03:12AM +0200, Ivo van Doorn wrote:
> > From: Ivo van Doorn <IvDoorn@gmail.com>
> >=20
> > Fix various little/big endian conversions.
> > rt2500pci should use cpu_to_le32 and rt2500usb should not.
>=20
> While you're at it can you add __be* annotations to the hardware
> datastructures so the endianess handling can be verified using sparse?

I am not sure if that would be a wise idea,
there is no byte ordering done in rt2500usb except for the EEPROM
contents which is little endian.
So when the module is used on a normal x86 platform, there won't be
any big endian structures or fields.

--nextPart1354372.gZZ9ach4Jz
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUhGsaqndE37Em0gRAsRjAKC9D8XfH0nloj7yNMHwEtoDITAHwQCfQWTh
u4x8TyHdmjzgoKibGhPVTPQ=
=Y6mH
-----END PGP SIGNATURE-----

--nextPart1354372.gZZ9ach4Jz--
