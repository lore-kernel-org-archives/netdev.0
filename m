From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for	vbus_driver
 objects
Date: Mon, 17 Aug 2009 10:16:40 -0400
Message-ID: <4A896648.9040707@gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A87C3B9.2040206@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigCE5F7E838B1ACC645A3192FF"
Cc: Ingo Molnar <mingo@elte.hu>, Gregory Haskins <ghaskins@novell.com>,
	kvm@vger.kernel.org, alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A87C3B9.2040206@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigCE5F7E838B1ACC645A3192FF
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 08/15/2009 01:32 PM, Ingo Molnar wrote:
>>> This will generally be used for hypervisors to publish any host-side
>>> virtual devices up to a guest.  The guest will have the opportunity
>>> to consume any devices present on the vbus-proxy as if they were
>>> platform devices, similar to existing buses like PCI.
>>>
>>>     =20
>> Is there a consensus on this with the KVM folks? (i've added the KVM
>> list to the Cc:)
>>   =20
>=20
> My opinion is that this is a duplication of effort and we'd be better
> off if everyone contributed to enhancing virtio, which already has
> widely deployed guest drivers and non-Linux guest support.
>=20
> It may have merit if it is proven that it is technically superior to
> virtio (and I don't mean some benchmark in some point in time; I mean
> design wise).  So far I haven't seen any indications that it is.
>=20


The design is very different, so hopefully I can start to convince you
why it might be interesting.

Kind Regards,
-Greg


--------------enigCE5F7E838B1ACC645A3192FF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqJZkgACgkQP5K2CMvXmqF9/QCfYH+FyJBxUb791cYylsF99ofb
zi4AnRZCzfj/XOTknrJUq5nZkMDdJ5VD
=635N
-----END PGP SIGNATURE-----

--------------enigCE5F7E838B1ACC645A3192FF--
