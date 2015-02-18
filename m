From: Matthew Thode <mthode@mthode.org>
Subject: Re: [PATCH] colons are invalid characters in netdev names
Date: Tue, 17 Feb 2015 19:33:25 -0600
Message-ID: <54E3EBE5.5090008@mthode.org>
References: <1424214942-17581-1-git-send-email-mthode@mthode.org> <20150217192803.21a63afd@uryu.home.lan>
Reply-To: mthode@mthode.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="6CClCEw6LEoQ4C5jNbsEfpkkuUpA0mWo3"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150217192803.21a63afd@uryu.home.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--6CClCEw6LEoQ4C5jNbsEfpkkuUpA0mWo3
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 02/17/2015 07:28 PM, Stephen Hemminger wrote:
> On Tue, 17 Feb 2015 17:15:42 -0600
> Matthew Thode <mthode@mthode.org> wrote:
>=20
>> colons are used as a separator in netdev device lookup in dev_ioctl.c
>>
>> Specific functions are SIOCGIFTXQLEN SIOCETHTOOL SIOCSIFNAME
>>
>> Signed-off-by: Matthew Thode <mthode@mthode.org>
>=20
> What is the exact sequence that causes the problem?
> SIOCSIFNAME already strips of colon.
>=20
>=20
It strips the name one access, not creation.  You can create a dummy
device and not access it, escaping doesn't seem to help.

ip link add name foo:asdasd type dummy
ip link del dev foo:asdasd              # will not be deleted

--=20
Matthew Thode


--6CClCEw6LEoQ4C5jNbsEfpkkuUpA0mWo3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCgAGBQJU4+vlAAoJEGSje+quGaTocCkP/iGbvKPCHIQLjYm1lS8aTsoP
OkOwh+GjKWPH/ty3++K3V28/WUfRDGTRlhv9+JHI78PI1Z6jXF+RwQ5kfkpoA0zR
J1ouUJgK/AfieuIcUfxe6vNt1zOgxqcTkyDerTIC2yV28PbZZIlYijD8FGR08TFd
bJ+LIipWjdyPtQtoTKnmI4sVakQHsIYEbpQPqUpPbRwJqrGA4ClsC0Ql3TYKRkCK
ZjuMw4/Hw3dPPpqKlBjuyP2bRgniP0VC/w/XM9sWu0NVascGtMvnWm9ohtPnTJbg
g+Ec/tMKThKThq1jyHFnCV6Ukx4Ii2zieIxMRPvfrQuk+r9SMPv2cYcukhZIUmeQ
+4rOUp/cDNM++uG2KwpcanSHWbIThVCslx2pTCMKASd8twhn7al1a+BqkDH1JEjJ
nMMhrH9QQ1R97WgqrQzs+KcB201Y2sHJb18grcFttQdAx6GSfNusVkm8AMz863m4
iFmxjpWAV2xhF96HTgvwkwM1b76hjtyf3UVqMkuUJ0saZGqrnhVoE6pQ+Ovym7nf
eg3TWQZ8QMX0UQVnMUJvsrWfgAE6enzpGWM/7/lXI77wgUs+2L5qLmPawaQ4zAYm
IhVqtowIL4q26bDJliZonbGqyzB3yWMxVEy9pTTruv2dEoq3+66EAekHNvwjnYRh
8dXxErid9Ynxe6EWFgty
=x76O
-----END PGP SIGNATURE-----

--6CClCEw6LEoQ4C5jNbsEfpkkuUpA0mWo3--
