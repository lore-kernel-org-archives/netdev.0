From: Jeroen Massar <jeroen@unfix.org>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Tue, 06 Dec 2005 00:10:59 +0100
Message-ID: <4394C903.40801@unfix.org>
References: <200512022253.19029.a1426z@gawab.com> <200512031646.45332.a1426z@gawab.com> <4391E4FC.1040200@candelatech.com> <20051205140057.GC24764@tuxdriver.com> <20051205174010.GA14101@buici.com> <43947FEB.7020504@unfix.org> <4394BCD5.1060505@psc.edu> <4394C3D4.9050909@unfix.org> <4394C5B6.8020301@psc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig83926B3E5F20A0488BFF1DC1"
Cc: Marc Singer <elf@buici.com>, Ben Greear <greearb@candelatech.com>,
	Al Boldi <a1426z@gawab.com>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <4394C5B6.8020301@psc.edu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig83926B3E5F20A0488BFF1DC1
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

John Heffner wrote:
> Jeroen Massar wrote:
>> John Heffner wrote:
>>
>>> Jeroen Massar wrote:
>>>
>>>> I wonder how many RFC's it violates. An interface must only answer
>>>> ARP's
>>>> on the interface that it is configured on, not anything else.
>>>
>>> Not true.  See RFC 1122, section 3.3.4.  The standard leaves this
>>> decision up to the implementation, for good reason.
>>
>>
>> RFC1122 is a document about multicast. ARP is broadcast see the very o=
ld
>>  RFC826/STD0037. Multicast didn't even work on much of the hardware fr=
om
>> the times that that document was written.
>=20
> ???  RFC 1122 is the Hosts Requirements RFC.  It applies to any host
> implementing IP.  Maybe you're thinking of 1112?

Oops, mixed up a number. 1122 refers to 826, with 1027 extending it
partially for situations where one is multihomed.
Section 3.3.4 of 1122 is about IP and not about ARP, which is, just like
IP directly on top of Ethernet.

Greets,
 Jeroen


--------------enig83926B3E5F20A0488BFF1DC1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (MingW32)
Comment: Jeroen Massar / http://unfix.org/~jeroen/

iD8DBQFDlMkDKaooUjM+fCMRAvTVAJ4oAxX01j9D9Z5aNYQ3liHHdeS5+QCgwJak
Ikzv7FDbJoQNul+6U0Iy9Cg=
=qFiX
-----END PGP SIGNATURE-----

--------------enig83926B3E5F20A0488BFF1DC1--
