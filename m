From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Fri, 13 Nov 2009 20:33:35 -0500
Message-ID: <4AFE08EF.2030308@gmail.com>
References: <20091002141407.30224.54207.stgit@dev.haskins.net> <20091110115335.GC6989@redhat.com> <4AF919020200005A000586A9@sinclair.provo.novell.com> <20091110131722.GA19645@redhat.com> <4AF9747E.8020408@novell.com> <20091110143652.GB19645@redhat.com> <4AF98A8C.9040201@novell.com> <20091114011229.GA18580@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigBA737AB8F05AE52174D4E607"
Cc: Gregory Haskins <ghaskins@novell.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.221.174]:35141 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753401AbZKNBdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 20:33:33 -0500
In-Reply-To: <20091114011229.GA18580@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigBA737AB8F05AE52174D4E607
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Herbert Xu wrote:
> On Tue, Nov 10, 2009 at 10:45:16AM -0500, Gregory Haskins wrote:
>> What I am getting at is as follows:  From a real basic perspective, yo=
u
>> can look at all of this as a simple synchronous call (i.e. sendmsg()).=

>> The "app" (be it a userspace app, or a guest) prepares a buffer for
>> transmission, and offers it to the next layer in the stack.  The app
>> must maintain the integrity of that buffer at least until the layer
>> below it signifies that it is "consumed".  This may mean its a
>> synchronous call, like sendmsg(), or it may be asynchronous, like AIO.=

>=20
> Neither sendmsg() nor sendfile() is synchronous in the way you
> imagine.

Well, not with respect to the overall protocol, of course not.  But with
respect to the buffer in question, it _has_ to be.  Or am I missing
something?

Kind Regards,
-Greg


--------------enigBA737AB8F05AE52174D4E607
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkr+CO8ACgkQP5K2CMvXmqEhTQCeKpXX7xDpVZO7/F+9whHygC5g
NmYAn0UZBVLGIloS9fy4iBDDaceQzhI7
=5DNH
-----END PGP SIGNATURE-----

--------------enigBA737AB8F05AE52174D4E607--
