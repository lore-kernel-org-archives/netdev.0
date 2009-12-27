From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Sun, 27 Dec 2009 08:34:46 -0500
Message-ID: <4B376276.3020105@gmail.com>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com> <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu> <4B3248F9.5030504@gmail.com> <4B327F3A.9020101@redhat.com> <4B328535.5040105@redhat.com> <4B33361E.3000605@gmail.com> <4B3729ED.50006@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig56C2C62987DFD7F3D660440F"
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752141AbZL0Nex@vger.kernel.org>
In-Reply-To: <4B3729ED.50006@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig56C2C62987DFD7F3D660440F
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/27/09 4:33 AM, Avi Kivity wrote:
> On 12/24/2009 11:36 AM, Gregory Haskins wrote:
>>> As a twist on this, the VMware paravirt driver interface is so
>>> hardware-like that they're getting hardware vendors to supply cards t=
hat
>>> implement it.  Try that with a pure software approach.
>>>     =20
>> Any hardware engineer (myself included) will tell you that, generally
>> speaking, what you can do in hardware you can do in software (think of=

>> what QEMU does today, for instance).  It's purely a cost/performance
>> tradeoff.
>>
>> I can at least tell you that is true of vbus.  Anything on the vbus si=
de
>> would be equally eligible for a hardware implementation, though there =
is
>> not reason to do this today since we have equivalent functionality in
>> baremetal already.
>=20
> There's a huge difference in the probability of vmware getting cards to=

> their spec, or x86 vendors improving interrupt delivery to guests,
> compared to vbus being implemented in hardware.

Thats not relevant, however.  I said in the original quote that you
snipped that I made it a software design on purpose, and you tried to
somehow paint that as a negative because vmware made theirs
"hardware-like" and you implied it could not be done with my approach
with the statement "try that with a pure software approach".  And the
bottom line is that the statement is incorrect and/or misleading.

>=20
>> The only motiviation is if you wanted to preserve
>> ABI etc, which is what vmware is presumably after.  However, I am not
>> advocating this as necessary at this juncture.
>>   =20
>=20
> Maybe AlacrityVM users don't care about compatibility, but my users do.=


Again, not relevant to this thread.  Making your interface
"hardware-like" buys you nothing in the end, as you ultimately need to
load drivers in the guest either way, and any major OS lets you extend
both devices and buses with relative ease.  The only counter example
would be if you truly were "hardware-exactly" like e1000 emulation, but
we already know that this means it is hardware centric and not
"exit-rate aware" and would perform poorly.  Otherwise "compatible" is
purely a point on the time line (for instance, the moment virtio-pci ABI
shipped), not an architectural description such as "hardware-like".



>=20



--------------enig56C2C62987DFD7F3D660440F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAks3YnYACgkQP5K2CMvXmqFN8QCfZArlawV3T2azxRyQxNI/KyD8
OWAAoIoPDe03DxE45/6XWqipjStEgnR0
=nAVs
-----END PGP SIGNATURE-----

--------------enig56C2C62987DFD7F3D660440F--
