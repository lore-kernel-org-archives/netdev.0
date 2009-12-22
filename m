From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 14:41:22 -0500
Message-ID: <4B3120E2.7070307@gmail.com>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu> <4B2F9582.5000002@gmail.com> <20091222075742.GB26467@elte.hu> <4B3103B4.4070708@gmail.com> <4B3115C1.4070303@redhat.com> <4B311ADA.4000700@gmail.com> <4B311D20.7020400@redhat.com> <4B311ECB.6040205@gmail.com> <4B312042.7010804@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig50247FF784F95F3FF76E2066"
Cc: Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:41910 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754478AbZLVTl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 14:41:26 -0500
In-Reply-To: <4B312042.7010804@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig50247FF784F95F3FF76E2066
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/22/09 2:38 PM, Avi Kivity wrote:
> On 12/22/2009 09:32 PM, Gregory Haskins wrote:
>> xinterface, as it turns out, is a great KVM interface for me and easy =
to
>> extend, all without conflicting with the changes in upstream.  The old=

>> way was via the kvm ioctl interface, but that sucked as the ABI was
>> always moving.  Where is the problem?  ioeventfd still works fine as
>> it is.
>>   =20
>=20
> It means that kvm locking suddenly affects more of the kernel.
>=20

Thats ok.  This would only be w.r.t. devices that are bound to the KVM
instance anyway, so they better know what they are doing (and they do).

-Greg


--------------enig50247FF784F95F3FF76E2066
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAksxIOIACgkQP5K2CMvXmqGQegCeJFYZWuAUJyCQ8FQwFIUMc7at
p7UAn2M2HWKIw9trJq0ZxH65DCFPX6xM
=bw6e
-----END PGP SIGNATURE-----

--------------enig50247FF784F95F3FF76E2066--
