From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Tue, 10 Nov 2009 10:47:49 -0500
Message-ID: <4AF98B25.3010007@novell.com>
References: <20091002141407.30224.54207.stgit@dev.haskins.net> <20091110115335.GC6989@redhat.com> <4AF919020200005A000586A9@sinclair.provo.novell.com> <20091110131722.GA19645@redhat.com> <4AF9747E.8020408@novell.com> <20091110144543.GC19645@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig346508D6DE70921A654D530F"
Cc: alacrityvm-devel@lists.sourceforge.net, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20091110144543.GC19645@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig346508D6DE70921A654D530F
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> On Tue, Nov 10, 2009 at 09:11:10AM -0500, Gregory Haskins wrote:
>>> You are comparing with skb destructors, not skb data destructors :) s=
kb
>>> data destructor is Rusty's patch which he wanted to use for vringfd. =
 I
>>> mean e.g. this:
>>> http://lists.openwall.net/netdev/2008/04/18/7
>> Ah, I wasn't aware.  I believe Anthony Ligouri had pointed me at this
>> same patch earlier this year.  However, more recently when I saw
>> skb->destructor() in mainline (seemingly from Rusty), I thought it had=

>> been accepted and didn't investigate further.
>=20
> skb->destructor seems to be there as far back as 2.2.0
> http://lxr.linux.no/#linux-old+v2.2.0/include/linux/skbuff.h
>=20

Right, I meant recent activity around it for fixing it up related to
leaks, etc.


--------------enig346508D6DE70921A654D530F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkr5iyUACgkQP5K2CMvXmqGHpgCffgjCZLw2XjuAKhYzmDQFD7JR
t0UAn1amKCMsLJ8AdJHEMVMahwKLcGCl
=0IiT
-----END PGP SIGNATURE-----

--------------enig346508D6DE70921A654D530F--
