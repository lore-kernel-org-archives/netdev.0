From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 09:03:21 -0400
Message-ID: <49D4B799.5080902@novell.com>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D47F11.6070400@redhat.com> <20090402091639.GA30126@gondor.apana.org.au> <49D484F5.2000400@redhat.com> <20090402092936.GA30333@gondor.apana.org.au> <49D487A6.407@redhat.com> <49D49C1F.6030306@novell.com> <49D4A89E.5090407@redhat.com> <49D4AFF7.1050603@novell.com> <49D4B308.2030007@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig3E461C1D46F841D9242FA7BF"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, anthony@codemonkey.ws,
	andi@firstfloor.org, linux-kernel@vger.kernel.org, agraf@suse.de,
	pmullaney@novell.com, pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	Mark McLoughlin <markmc@redhat.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D4B308.2030007@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig3E461C1D46F841D9242FA7BF
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Gregory Haskins wrote:
>
> =20
>
>>> It's more of a "schedule and forget" which I think brings you the
>>> win.  The host disables notifications and schedules the actual tx wor=
k
>>> (rx from the host's perspective).  So now the guest and host continue=

>>> producing and consuming packets in parallel.  So long as the guest is=

>>> faster (due to the host being throttled?), notifications continue to
>>> be disabled.
>>>    =20
>> Yep, when the "producer::consumer" ratio is > 1, we mitigate
>> signaling. When its < 1, we signal roughly once per packet.
>>
>> =20
>>> If you changed your rx_isr() to process the packets immediately
>>> instead of scheduling, I think throughput would drop dramatically.
>>>    =20
>> Right, that is the point. :) This is that "soft asic" thing I was
>> talking about yesterday.
>>  =20
>
> But all that has nothing to do with where the code lives, in the
> kernel or userspace.

Agreed, but note Ive already stated that some of my boost is likely from
in-kernel, while others are unrelated design elements such as the
"soft-asic" approach (you guys dont read my 10 page emails, do you? ;).=20
I don't deny that some of my ideas could be used in userspace as well
(Credit if used would be appreciated :).

-Greg



--------------enig3E461C1D46F841D9242FA7BF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknUt5oACgkQlOSOBdgZUxliawCdFchYctOROPBKauBNeWWe/YEz
G4kAn2VLxCLuOxSYPW+WSjcixskQS2Jh
=VVVL
-----END PGP SIGNATURE-----

--------------enig3E461C1D46F841D9242FA7BF--
