From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Thu, 24 Dec 2009 04:36:30 -0500
Message-ID: <4B33361E.3000605@gmail.com>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com> <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu> <4B3248F9.5030504@gmail.com> <4B327F3A.9020101@redhat.com> <4B328535.5040105@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig24B2B51B00B69B2008494E7A"
Cc: Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Andi Kleen <andi@firstfloor.org>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:14918 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753884AbZLXJge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 04:36:34 -0500
In-Reply-To: <4B328535.5040105@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig24B2B51B00B69B2008494E7A
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/23/09 4:01 PM, Avi Kivity wrote:
> On 12/23/2009 10:36 PM, Avi Kivity wrote:
>> On 12/23/2009 06:44 PM, Gregory Haskins wrote:
>>>
>>>>   - Are a pure software concept
>>> By design.  In fact, I would describe it as "software to software
>>> optimized" as opposed to trying to shoehorn into something that was
>>> designed as a software-to-hardware interface (and therefore has
>>> assumptions about the constraints in that environment that are not
>>> applicable in software-only).
>>>
>>
>> And that's the biggest mistake you can make.  Look at Xen, for
>> instance.  The paravirtualized the fork out of everything that moved
>> in order to get x86 virt going.  And where are they now? x86_64
>> syscalls are slow since they have to trap to the hypervisor and
>> (partially) flush the tlb.  With npt or ept capable hosts performance
>> is better for many workloads on fullvirt.  And paravirt doesn't
>> support Windows.  Their unsung hero Jeremy is still trying to upstream=

>> dom0 Xen support.  And they get to support it forever.
>>
>> VMware stuck with the hardware defined interfaces.  Sure they had to
>> implement binary translation to get there, but as a result, they only
>> have to support one interface, all guests support it, and they can
>> drop it on newer hosts where it doesn't give them anything.
>=20
> As a twist on this, the VMware paravirt driver interface is so
> hardware-like that they're getting hardware vendors to supply cards tha=
t
> implement it.  Try that with a pure software approach.

Any hardware engineer (myself included) will tell you that, generally
speaking, what you can do in hardware you can do in software (think of
what QEMU does today, for instance).  It's purely a cost/performance
tradeoff.

I can at least tell you that is true of vbus.  Anything on the vbus side
would be equally eligible for a hardware implementation, though there is
not reason to do this today since we have equivalent functionality in
baremetal already.  The only motiviation is if you wanted to preserve
ABI etc, which is what vmware is presumably after.  However, I am not
advocating this as necessary at this juncture.

So sorry, your statement is not relevant.

-Greg




>=20



--------------enig24B2B51B00B69B2008494E7A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkszNh4ACgkQP5K2CMvXmqH1iQCePJc5KaloVUoUe1VbwPUwuIO7
V/sAniQm/2DWWxyIv3xGAB7ntfZj4w1W
=RFQj
-----END PGP SIGNATURE-----

--------------enig24B2B51B00B69B2008494E7A--
