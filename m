From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH] i40e: constify i40e_client_ops structure
Date: Fri, 13 May 2016 16:42:52 -0400
Message-ID: <7b2cd30a-77c3-4204-c2cf-df5a2870b443@redhat.com>
References: <1462104443-30724-1-git-send-email-Julia.Lawall@lip6.fr>
 <0c2df9ca-64bd-ac73-9071-f4d619887df8@redhat.com>
 <1463168405.2612.23.camel@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="qNWrvwFh2QVa1sF9q7gn4CFd7nFXSRqlO"
Cc: kernel-janitors@vger.kernel.org, linux-rdma@vger.kernel.org,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Tatyana Nikolova <tatyana.e.nikolova@intel.com>,
	Shiraz Saleem <shiraz.saleem@intel.com>,
	Mustafa Ismail <mustafa.ismail@intel.com>,
	Chien Tin Tung <chien.tin.tung@intel.com>,
	Faisal Latif <faisal.latif@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Julia Lawall <julia.lawall@lip6.fr>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463168405.2612.23.camel@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--qNWrvwFh2QVa1sF9q7gn4CFd7nFXSRqlO
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 05/13/2016 03:40 PM, Jeff Kirsher wrote:
> On Fri, 2016-05-13 at 12:50 -0400, Doug Ledford wrote:
>> On 05/01/2016 08:07 AM, Julia Lawall wrote:
>>> The i40e_client_ops structure is never modified, so declare it as
>> const.
>>> =20
>>> Done with the help of Coccinelle.
>>> =20
>>> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
>>
>> Thanks, applied.
>=20
> I already have this patch queued up to push through David Miller's net-=
next=20
> tree.
>=20
> Julia- please do not shotgun blast several maintainers and several list=
s,
> it causes confusion on who is *REALLY* going to accept and apply the pa=
tch.
> Please use scripts/get_maintainer.pl to get the correct mailing lists a=
nd
> maintainers to add to the To: and CC: lines.
>=20

I've dropped it from my tree.  There won't be a conflict.

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--qNWrvwFh2QVa1sF9q7gn4CFd7nFXSRqlO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXNjxMAAoJELgmozMOVy/dTLkP/RNLyYE+Eih1PRkb8xWrsGrj
JCzANSluRVpTPLZWEm+2w54tsDi5ZZOdXmHHWJEBIJ+2Cq2Twu5URjUYTCM07anL
g8P+UFMCKpoSlpFwinUbnNl4KHNdfGwvpHgvTz7Cl6WEInujKh8wCZORe1dMVVUD
nOCLnCQd9Sa9UlBAGK6Im14YorX1qp+rhuqWhrdqUufv5fWH9T3YTeKlXtrKRl1N
4fZ8zLQ4RhHF/EI6USEtdVfSZXD29i5jvWo9klJxSwqM5QTnLbb5Y2Q9kbXrPWoJ
F1cXDdZ50wHcCtvmZRjjjPCnXEHh/cTJRCFPjxsS+/lJIj3ECiTiHci0peuaYHaE
WT6uluntfuNszpxul2nNBBW0gWSYKvQLrBtipKgc0v1YiERfaGhiMoMkYX5XIvek
ZTJmuLYvIYnRkjagkrMcBD8c3NepiiYUErczKvrwOIDDci7UKeLesWMZI+h03ff5
cUM2oDRKtEi1aAlQ7Wdp6kCW+1L81+5NXj8mTMMoo1oSz/JWY8nwjP2FXIdPwQqV
DIMsAeGSJ/WddcnXJV14oVcvG7yiO+2u8pAMZ3jNBKJc03uC1YproqtasewVMq4/
IFwNy4Wh4KHw8IZolAD48fZT3TCV5GeippdwOGSkLhnru5ZMelFdkvJ1lthWP67D
I+C8PNkj74nVP0qIIfIZ
=OgVU
-----END PGP SIGNATURE-----

--qNWrvwFh2QVa1sF9q7gn4CFd7nFXSRqlO--
