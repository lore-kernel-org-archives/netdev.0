From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] checkpatch.pl: Fix warnings on code comments
Date: Mon, 28 Jan 2013 12:56:13 -0800
Message-ID: <1359406573.2099.11.camel@jtkirshe-mobl>
References: <1359286539-18395-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20130127.185910.1743425400733006443.davem@davemloft.net>
	 <1359341805.2255.56.camel@jtkirshe-mobl>
	 <20130127.220728.634216960903942581.davem@davemloft.net>
	 <804857E1F29AAC47BF68C404FC60A1843ABC3058@ORSMSX102.amr.corp.intel.com>
	 <1359394228.31480.7.camel@joe-AO722>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-dEpQe/sXXXdDwmwar9dI"
Cc: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	David Miller <davem@davemloft.net>,
	"apw@canonical.com" <apw@canonical.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1359394228.31480.7.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-dEpQe/sXXXdDwmwar9dI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-01-28 at 09:30 -0800, Joe Perches wrote:
> On Mon, 2013-01-28 at 17:17 +0000, Allan, Bruce W wrote:
> > David Miller Sent: Sunday, January 27, 2013 7:07 PM
> > > From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > > > So will you be fine with cleanup patches which go through and
> > > > convert all the existing code comments to the desired format?
> > > Sure.
> > Not all Intel drivers...e1000e already conforms to the comment style :-=
)
>=20
> In case anyone cares, here's a perl regex
> to do network comment style conversion.
>=20
>         $text =3D~ s@/\*[ \t]*\n[ \t]*\*@/*@g;
>         $text =3D~ s@/\*([ \t]*)([^\n]+)\n[ \t]*\*/@/\*$1$2 \*/@g;
>=20
> (assumes the entire file is in $text)
>=20
> It creates a ~220KB diff for drivers/net/ethernet/intel/
> that I won't post.
>=20

Thanks Joe, I will get patches to take care of the Intel drivers (minus
e1000e since Bruce has already completed that work).

--=-dEpQe/sXXXdDwmwar9dI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRBuXtAAoJEOVv75VaS+3OHf4P/j6s7EUM36/M/xrBVgHOq0RN
4CY8rg85ocrvREv3JP0ojPn5zBjhlmmLvlNZTvjoG+EVilqTZJ9B2oxGo67t8Nx9
0+NDDov2xFWF7Gxp82gSNNBITcytB3dxqKyrQQYzUJpym5epJUxMpz4Ws1f8Q6hB
pYbaGsKnFVn5jwt7/hNVH17ocDH6Oa4nAnmoRpyJT4t0ZcwWcQtuHXfYkPU0U2fg
o8xJgigBbArmApj48gGqBm4ewsNYKMLr+BGZpKbgaB++/wI6CiQoQ+XOpzKIRYE7
DmfR8F2wfrpGZVTKoO+EbbFm0w1E9SG8TIBX5yrOdeuKuBqbTM4B/E1e9Ymqa9Sr
qvHMGps1YHuYf+CPQGJG9umcX+gj4S9RLeHCzmgG6JkWdiNp0THwtoHBiD7N1EW/
y8nTyjgAVH9RhKePio1xDSr8FvJG25lt4DBqWd9sZM48gYkJCyPA+7VbRGXi20Bd
w1pnDCZ7yMEILpsihvxPn1uS1fZnA3uJd933cAQWDbj7/9pU4GKNznL8eO7vZACj
VeXNXJpHEFpZr7Nylmo2OfKcfvIWv49mw0l/3vqB0k9SM0uPcYf/ZwYXK9Z5p9DZ
fzjsWcqm+vsGQlbqSRLC1RZcyXJKeL3tietscXBa4d56CM8yXuE2xmDJ+BEpYAy8
iHxtYA7liIf1ic91MwkU
=4CId
-----END PGP SIGNATURE-----

--=-dEpQe/sXXXdDwmwar9dI--
