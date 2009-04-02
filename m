From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 09:22:02 -0400
Message-ID: <49D4BBFA.2040106@novell.com>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D487A6.407@redhat.com> <49D49C1F.6030306@novell.com> <200904022243.21088.rusty@rustcorp.com.au> <49D4B4A3.5070008@novell.com> <49D4B87D.2000202@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigB09209B12E70786EB412F1F2"
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	anthony@codemonkey.ws, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:41590 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757AbZDBNT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 09:19:58 -0400
In-Reply-To: <49D4B87D.2000202@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigB09209B12E70786EB412F1F2
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Gregory Haskins wrote:
>> Rusty Russell wrote:
>> =20
>>> On Thursday 02 April 2009 21:36:07 Gregory Haskins wrote:
>>>     =20
>>>> You do not need to know when the packet is copied (which I currently=

>>>> do).  You only need it for zero-copy (of which I would like to
>>>> support,
>>>> but as I understand it there are problems with the reliability of
>>>> proper
>>>> callback (i.e. skb->destructor).
>>>>          =20
>>> But if you have a UP guest,
>>>    =20
>>
>> I assume you mean UP host ;)
>>
>>  =20
>
> I think Rusty did mean a UP guest, and without schedule-and-forget.
That doesnt make sense to me, tho.  All the testing I did was a UP
guest, actually.  Why would I be constrained to run without the
scheduling unless the host was also UP?

>
>> Hmm..well I was hoping to be able to work with you guys to make my
>> proposal fit this role.  If there is no interest in that, I hope that =
my
>> infrastructure itself may still be considered for merging (in *some*
>> tree, not -kvm per se) as I would prefer to not maintain it out of tre=
e
>> if it can be avoided.
>
> The problem is that we already have virtio guest drivers going several
> kernel versions back, as well as Windows drivers.  We can't keep
> changing the infrastructure under people's feet.

Well, IIUC the virtio code itself declares the ABI as unstable, so there
technically *is* an out if we really wanted one.  But I certainly
understand the desire to not change this ABI if at all possible, and
thus the resistance here.

However, theres still the possibility we can make this work in an ABI
friendly way with cap-bits, or other such features.  For instance, the
virtio-net driver could register both with pci and vbus-proxy and
instantiate a device with a slightly different ops structure for each or
something.  Alternatively we could write a host-side shim to expose vbus
devices as pci devices or something like that.

-Greg

>
>



--------------enigB09209B12E70786EB412F1F2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknUu/oACgkQlOSOBdgZUxnwbgCffjxm9APFBe2d0W2QO716bWo7
DnUAn0aVDm2XiNSFwh8u3n+GJ44JLg9e
=zOOd
-----END PGP SIGNATURE-----

--------------enigB09209B12E70786EB412F1F2--
