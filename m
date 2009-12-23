From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [Alacrityvm-devel] [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 13:15:15 -0500
Message-ID: <4B325E33.8060407@gmail.com>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org>	<4B30E654.40702@codemonkey.ws>	<200912221701.56840.bzolnier@gmail.com>	<4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu>	<20091223101340.GC20539@basil.fritz.box> <4B31EF65.6070000@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig2680697E9F7A6F0ACA8C1703"
Cc: Andi Kleen <andi@firstfloor.org>, kvm@vger.kernel.org,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>, torvalds@linux-foundation.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4B31EF65.6070000@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig2680697E9F7A6F0ACA8C1703
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/23/09 5:22 AM, Avi Kivity wrote:

>=20
> There was no attempt by Gregory to improve virtio-net.

If you truly do not understand why your statement is utterly wrong at
this point in the discussion, I feel sorry for you.  If you are trying
to be purposely disingenuous, you should be ashamed of yourself.  In any
case, your statement is demonstrably bogus, but you should already know
this given that we talked about at least several times.

To refresh your memory: http://patchwork.kernel.org/patch/17428/

In case its not blatantly clear, which I would hope it would be to
anyone that understands the problem space:  What that patch would do is
allow an unmodified virtio-net to bridge to a vbus based virtio-net
backend.  (Also note that this predates vhost-net by months (the date in
that thread is 4/9/2009) in case you are next going to try to argue that
it does nothing over vhost-net).

This would mean that virtio-net would gain most of the benefits I have
been advocating (fewer exits, cheaper exits, concurrent execution, etc).
 So this would very much improve virtio-net indeed, given how poorly the
current backend was performing.  I tried to convince the team to help me
build it out to completion on multiple occasions, but that request was
answered with "sorry, we are doing our own thing instead".  You can say
that you didn't like my approach, since that is a subjective opinion.
But to say that I didn't attempt to improve it is a flat out wrong, and
I do not appreciate it.

-Greg




--------------enig2680697E9F7A6F0ACA8C1703
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAksyXjMACgkQP5K2CMvXmqFN1gCeO1NX9PRck/JEQAXNtcnFwFNU
ZOYAn3u08TTjZIbPVuwxNbpoENn28m8J
=Kqr0
-----END PGP SIGNATURE-----

--------------enig2680697E9F7A6F0ACA8C1703--
