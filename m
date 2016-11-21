From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH] VSOCK: add loopback to virtio_transport
Date: Mon, 21 Nov 2016 13:40:53 +0000
Message-ID: <20161121134053.GE15478@stefanha-x1.localdomain>
References: <1479397763-22319-1-git-send-email-stefanha@redhat.com>
 <20161119.220804.755313313976863187.davem@davemloft.net>
 <58311507.7070707@gmail.com>
 <20161119.221643.2303914168886226654.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="T6xhMxlHU34Bk0ad"
Cc: john.fastabend@gmail.com, netdev@vger.kernel.org,
        cavery@redhat.com, imbrenda@linux.vnet.ibm.com, jhansen@vmware.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43408 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753975AbcKUNk5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 08:40:57 -0500
Content-Disposition: inline
In-Reply-To: <20161119.221643.2303914168886226654.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--T6xhMxlHU34Bk0ad
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Nov 19, 2016 at 10:16:43PM -0500, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Sat, 19 Nov 2016 19:14:15 -0800
>=20
> > On 16-11-19 07:08 PM, David Miller wrote:
> >> From: Stefan Hajnoczi <stefanha@redhat.com>
> >> Date: Thu, 17 Nov 2016 15:49:23 +0000
> >>=20
> >>> @@ -159,6 +199,10 @@ virtio_transport_send_pkt(struct virtio_vsock_pk=
t *pkt)
> >>>  		return -ENODEV;
> >>>  	}
> >>> =20
> >>> +	if (le32_to_cpu(pkt->hdr.dst_cid) =3D=3D vsock->guest_cid) {
> >>> +		return virtio_transport_send_pkt_loopback(vsock, pkt);
> >>> +	}
> >>> +
> >>=20
> >> A single-statement basic block should get surrounding curly
> >> braces.
> >>=20
> >=20
> > Should _not_ get curly braces in case it wasn't obvious ;)
>=20
> Indeed, thanks for the correction :)

Thanks, I'll remember to run checkpatch.pl and send v2.

Stefan

--T6xhMxlHU34Bk0ad
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYMvllAAoJEJykq7OBq3PI0R0IALhiHho7sPv6/yt0kQ65+ioF
8Zy1RPPgLncezxzM51y2yulvQvsA9lJ+ySUzUpvinANYl0IDuTs6psU8Px/Y9Abd
tWBR3gRYkIQ74ynfZstmxlWk6+Uqklz8uV9KG7+04QZzUeGY6tGc4cuzmpKjmUgp
7nZ74jIdRCKjAcZKZzyO1mlIy0j0cqaACwCg5fcGbGlhfrmpffrIwKKRPX6aGKc5
1ua1JyjjfIkjQht/yoP1rNxOtO4iQsKQ7jjrSP+pr1dJNDBGIV2/DevXgzyNjx0d
EGJtWennAKHr7K/CkFOshuBmlR/oT5c30qWHtamLx94iaA/+bRbzPN0QCpdzHWg=
=yH/Z
-----END PGP SIGNATURE-----

--T6xhMxlHU34Bk0ad--
