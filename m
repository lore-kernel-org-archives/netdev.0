From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 03 Apr 2009 14:32:39 -0400
Message-ID: <49D65647.2000502@novell.com>
References: <49D469D2020000A100045FA1@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D4CB38.5030205@redhat.com> <49D4DA54.3090401@novell.com> <49D4DE82.5020306@redhat.com> <49D4F97F.6040507@novell.com> <49D5F669.1070502@redhat.com> <49D6240B.4080809@novell.com> <20090403170920.GM18394@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig3053C0255016E2D5F75A9B91"
Cc: Avi Kivity <avi@redhat.com>,
	Patrick Mullaney <pmullaney@novell.com>, anthony@codemonkey.ws,
	andi@firstfloor.org, herbert@gondor.apana.org.au,
	Peter Morreale <PMorreale@novell.com>, rusty@rustcorp.com.au,
	agraf@suse.de, kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090403170920.GM18394@sequoia.sous-sol.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig3053C0255016E2D5F75A9B91
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Chris Wright wrote:
> * Gregory Haskins (ghaskins@novell.com) wrote:
>  =20
>> Let me ask you this:  If you had a clean slate and were designing a
>> hypervisor and a guest OS from scratch:  What would you make the bus
>> look like?
>>    =20
>
> Well, virtio did have a relatively clean slate. And PCI (as _one_
> transport option) is what it looks like.  It's not the only transport
> (as Avi already mentioned it works for s390, for example).
>  =20

Got it.  Thanks.

> BTW, from my brief look at vbus, it seems pretty similar to xenbus.
>  =20

If you are referring to the guest side interface, it was actually
inspired by lguest's bus (I forget what Rusty called it now, though). =20
I think I actually declared that in the original patch series I put out
1.5 years ago, but I might have inadvertently omitted that on this
go-round.

I think XenBus is more of an event channel infrastructure, isn't it?=20
But in any case, I think the nature of getting PV drivers into a guest
is relatively similar, so I wouldn't be surprised if there were
parallels in quite a few of the implementations.  In fact, I chose a
generic name like "vbus" in hopes that it could be used across different
hypervisors. :)

-Greg


--------------enig3053C0255016E2D5F75A9B91
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknWVkgACgkQlOSOBdgZUxnBbwCbBExc8PDzX/IbW7luRoaFEccu
sMQAn3Z2oH5rv4HGfJ2dtaoIjrCkBTB9
=7VEH
-----END PGP SIGNATURE-----

--------------enig3053C0255016E2D5F75A9B91--
