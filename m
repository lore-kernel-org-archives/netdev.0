From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: AF_VSOCK status
Date: Tue, 12 Apr 2016 15:03:01 +0100
Message-ID: <20160412140301.GC29405@stefanha-x1.localdomain>
References: <5703B0F3.7050700@nagafix.co.uk>
 <20160406092609.GA17538@stefanha-x1.localdomain>
 <570B9021.5050709@nagafix.co.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dkEUBIird37B8yKS"
Cc: netdev@vger.kernel.org
To: Antoine Martin <antoine@nagafix.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34109 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932221AbcDLODE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2016 10:03:04 -0400
Content-Disposition: inline
In-Reply-To: <570B9021.5050709@nagafix.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--dkEUBIird37B8yKS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 11, 2016 at 06:53:05PM +0700, Antoine Martin wrote:
> > There are a few existing ways to achieve that without involving=20
> > virtio-vsock: vhost-user or ivshmem.
> Yes, I've looked at those and they seem a bit overkill for what we
> want to achieve. We don't want sharing with multiple guests, or
> interrupts.
> All we want is a chunk of host memory to be accessible from the guest..

ivshmem does that.  It operates in two modes, it sounds like you want
the first and simpler mode ("ivshmem-plain").

Take a look at hw/misc/ivshmem.c in QEMU.

Stefan

--dkEUBIird37B8yKS
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXDQAVAAoJEJykq7OBq3PIisAIALBSoMmzvpTCTrRtv7iDoPpp
/CnFeiQL3NMRVJMnpfDSHGmzPsB8i2UXpcsVKYmknln3lwB1cC6MNhqbyvqVdhaT
ICXB+B9Z63bWP5iWWYEATr/oYiEgvFs0toouo3kbDAksUQAc5zB3QAZINdzIkrok
fRQR2SBPXaADHq7Z8FkymJFZxQlpb9KvABSTH1BhWpx96/4TFU9SCYqIQdQk2CME
GjIvWdK5KPqpd54HrVLfhT6Y37quWRDF0neOa4a26j1UAK3d1DS+xTEYbfzKDDgk
tEUKDhc60pM6jDmhslOP98tZpR9QVcUL7WhaDQTNyDT4Y9VAk+uncEjJUYWM2Jg=
=SUAt
-----END PGP SIGNATURE-----

--dkEUBIird37B8yKS--
