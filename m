From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model
Date: Tue, 18 Aug 2009 09:19:35 -0400
Message-ID: <4A8AAA67.8060602@gmail.com>
References: <4A8A67ED0200005A000528F5@sinclair.provo.novell.com> <4A8A67F70200005A000528F8@sinclair.provo.novell.com> <4A8A67F70200005A000528F8@sinclair.provo.novell.com> <4A8AA0C6.805@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD249D2F1B3945978A4677231"
Cc: Gregory Haskins <GHaskins@novell.com>, mingo@elte.hu,
	alacrityvm-devel@lists.sourceforge.net, mst@redhat.com,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A8AA0C6.805@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD249D2F1B3945978A4677231
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 08/18/2009 03:36 PM, Gregory Haskins wrote:
>> Yeah, I agree.  I am not advocating we expend energy on this now.  But=

>> my thoughts at the time were that that particular problem can be
>> solved at io-setup time with some kind of call to qualify the address.=

>>
>> Iow: a slow path call with the address would return flags on whether
>> iowrite() should do a real io, or a IOoHC.
>>   =20
>=20
> Yes, it could work, though we'd need somewhere to stow this
> information.  IIRC Arnd suggested a bit from the address itself.
>=20

Yeah, exactly.  I think MMIO is particularly challenging because I don't
know if there are any bits left to use.  But like I said, its a problem
for another day IMO.

-Greg


--------------enigD249D2F1B3945978A4677231
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqKqmcACgkQP5K2CMvXmqFNrQCdEsgJJ5do/n7SewSSSI7fleak
iqEAni6IUvmvR1VpOsMQp4jM3/KI02XZ
=snOs
-----END PGP SIGNATURE-----

--------------enigD249D2F1B3945978A4677231--
