From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCHv2 0/2] vhost: a kernel-level virtio server
Date: Tue, 11 Aug 2009 19:49:37 -0400
Message-ID: <4A820391.1090404@gmail.com>
References: <20090811212743.GA26309@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA223C963729B04B1689E60E6"
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
 kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu,
 linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20090811212743.GA26309@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA223C963729B04B1689E60E6
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> This implements vhost: a kernel-level backend for virtio,
> The main motivation for this work is to reduce virtualization
> overhead for virtio by removing system calls on data path,
> without guest changes. For virtio-net, this removes up to
> 4 system calls per packet: vm exit for kick, reentry for kick,
> iothread wakeup for packet, interrupt injection for packet.
>=20
> Some more detailed description attached to the patch itself.
>=20
> The patches are against 2.6.31-rc4.  I'd like them to go into linux-nex=
t
> and down the road 2.6.32 if possible.  Please comment.

I will add this series to my benchmark run in the next day or so.  Any
specific instructions on how to set it up and run?

Regards,
-Greg


--------------enigA223C963729B04B1689E60E6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqCA5EACgkQP5K2CMvXmqHIvQCfYcoxCyKZvGg3C6EAOrpAEwIH
JmkAnRmvb/eJZIoYNF9JHmDPGvTAdvT/
=dirP
-----END PGP SIGNATURE-----

--------------enigA223C963729B04B1689E60E6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
