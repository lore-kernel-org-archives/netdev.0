From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Thu, 24 Dec 2009 04:31:13 -0500
Message-ID: <4B3334E1.9020401@gmail.com>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com> <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu> <4B3248F9.5030504@gmail.com> <4B327F3A.9020101@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig6F1D242F29ABF64475662726"
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
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4B327F3A.9020101@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig6F1D242F29ABF64475662726
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/23/09 3:36 PM, Avi Kivity wrote:
> On 12/23/2009 06:44 PM, Gregory Haskins wrote:
>>
>>>   - Are a pure software concept
>>>     =20
>> By design.  In fact, I would describe it as "software to software
>> optimized" as opposed to trying to shoehorn into something that was
>> designed as a software-to-hardware interface (and therefore has
>> assumptions about the constraints in that environment that are not
>> applicable in software-only).
>>
>>   =20
>=20
> And that's the biggest mistake you can make.

Sorry, that is just wrong or you wouldn't have virtio either.

>  Look at Xen, for
> instance.  The paravirtualized the fork out of everything that moved in=

> order to get x86 virt going.  And where are they now? x86_64 syscalls
> are slow since they have to trap to the hypervisor and (partially) flus=
h
> the tlb.  With npt or ept capable hosts performance is better for many
> workloads on fullvirt.  And paravirt doesn't support Windows.  Their
> unsung hero Jeremy is still trying to upstream dom0 Xen support.  And
> they get to support it forever.

We are only talking about PV-IO here, so not apples to apples to what
Xen is going through.

>=20
> VMware stuck with the hardware defined interfaces.  Sure they had to
> implement binary translation to get there, but as a result, they only
> have to support one interface, all guests support it, and they can drop=

> it on newer hosts where it doesn't give them anything.

Again, you are confusing PV-IO.  Not relevant here.   Afaict, vmware,
kvm, xen, etc, all still do PV-IO and likely will for the foreseeable
future.

-Greg


--------------enig6F1D242F29ABF64475662726
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkszNOEACgkQP5K2CMvXmqH8eQCeKwrgu5YaVdyI6IAve/v8J437
HdgAnitvdnltkpz2ErIxG0ygN4gk6j/4
=GoeV
-----END PGP SIGNATURE-----

--------------enig6F1D242F29ABF64475662726--
