From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [linux-stable] i40e: Don't stop driver probe when querying DCB
 config fails
Date: Wed, 13 Aug 2014 13:24:51 -0700
Message-ID: <1407961491.2308.17.camel@jtkirshe-mobl.jf.intel.com>
References: <1407929455-8443-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20140813.124340.1193598133586058303.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1e0m3/wdK5FTdi2A/ogu"
Cc: gregkh@linuxfoundation.org, neerav.parikh@intel.com,
	netdev@vger.kernel.org, stable@vger.kernel.org,
	catherine.sullivan@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20140813.124340.1193598133586058303.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-1e0m3/wdK5FTdi2A/ogu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-08-13 at 12:43 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Wed, 13 Aug 2014 04:30:55 -0700
>=20
> > From: Neerav Parikh <neerav.parikh@intel.com>
> >=20
> > Commit id: 014269ff376f552363ecdab78d3d947fbe2237d9 in Linus's tree
> > should be queued up for stable 3.14 & 3.15 since the i40e driver will
> > not load when DCB is enabled, unless this patch is applied.
> >=20
> > In case of any AQ command to query port's DCB configuration fails
> > during driver's probe time; the probe fails and returns an error.
> >=20
> > This patch prevents this issue by continuing the driver probe even
> > when an error is returned.
> >=20
> > Also, added an error message to dump the AQ error status to show what
> > error caused the failure to get the DCB configuration from firmware.
> >=20
> > Change-ID: Ifd5663512588bca684069bb7d4fb586dd72221af
> > Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
> > Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> This is a very confusing submission.
>=20
> Is this an already applied patch that you want accepted into the -stable
> tree?  If so, which tree(s)?

Sorry, yes.  It is current in 3.16.y, and we would like it queued up for
3.14.y and 3.15.y stable trees.  I got a bit confused when I went to
submit this to stable and saw that networking stable patches were
handled differently that other stable patches.  I tried to make my
request clear by writing that first paragraph in the patch description,
but I probably just muddied the water instead.

It is just easier, when the developers tell me to begin with that a
patch needs to go into stable when they first submit the patch.  Which
was not the case for this patch, grrr.

--=-1e0m3/wdK5FTdi2A/ogu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJT68mTAAoJEOVv75VaS+3OxkYP/A12a4Rab+O8n5xIDwnrZDZl
xVVYxM0KKC4QoOYPIj0qDoFrVrZMD4j1awZjgyQJNSGI7Ak/pwHKpa8uB6pr1TNh
ShFrcBbgH3eazi4ve+HvxS6A2etQUOCXo0nouYoji/sp/NphOXBuBgJ5m7OAZDBy
piF2ysP9ddPFt0fo4jol3ehycWz9txS4ByPcOEyOhX28x30HiCJZBIry1aqQwo3S
PzHJvDZhR60icQyyuJp10AVO8KAwt+Q7SlAB/z64p+3Pv6kzbu7zSe3PLR5OBL+K
1nmXWQF1TIaqj1TIIJSxudrci0qwd527nMh2rlAk9+HIXhEzhxApxE+LldGKbbtd
TmKEgceA3TdqUVcqpEosA9QyAC6yuCi8PVn3R6oYPrO0E1qomVUTdeCr3YKSyNZh
09GpX+Y1gzQ848rSkn90BduOJEoS6472Td1z0i2aAGUOvBi9NkorQXphNe1zfWHs
hjSPv7CqmXMaWOVJMkq0VM/0ARjJfLcvNJTWa8Wi/h1qTzsbQ+AQR0WQFuqUv1jJ
/LtGdnN71VUJSuMb6BOoH0UJpvZaR0BaaWel6j02o5ODop8lsb+yh4sCXpw9WdES
+SXA4YXVIP5m2EALymuOxLpnnbhgs2HJyzAdYuFIloSMtkJ5eNY/DpwM3UDhxgMn
pldv6UDuCvLV6zYdcksk
=mXUk
-----END PGP SIGNATURE-----

--=-1e0m3/wdK5FTdi2A/ogu--
