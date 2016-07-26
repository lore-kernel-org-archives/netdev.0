From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 3/2] e1000e: convert systim overflow check to
 use flags2
Date: Tue, 26 Jul 2016 10:53:55 -0700
Message-ID: <1469555635.2851.10.camel@intel.com>
References: <20160725105648.00000dda@unknown>
	 <1469554746-410-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-YufOot3VoGvmoTFLpVHu"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:5895 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756175AbcGZRyG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 13:54:06 -0400
In-Reply-To: <1469554746-410-1-git-send-email-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-YufOot3VoGvmoTFLpVHu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-07-26 at 13:39 -0400, Jarod Wilson wrote:
> Per Jesse Brandeburg, e1000e should be using flags for this sort of
> thing.
>=20
> Littering functional code with device-specific checks is much messier
> than
> simply checking a flag, and having device-specific init set flags as
> needed.
> There are probably a number of other cases in the e1000e code that
> could/should be converted similarly.
>=20
> At present, this patch is a follow-up to the previously submitted 2
> patches, but I can redo the series to omit the conversion to a switch
> entirely, if so desired.
>=20
> Suggested-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: intel-wired-lan@lists.osuosl.org
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
> ---
> =C2=A0drivers/net/ethernet/intel/e1000e/82571.c=C2=A0=C2=A0 |=C2=A0 6 +++=
+--
> =C2=A0drivers/net/ethernet/intel/e1000e/e1000.h=C2=A0=C2=A0 |=C2=A0 1 +
> =C2=A0drivers/net/ethernet/intel/e1000e/ich8lan.c |=C2=A0 3 ++-
> =C2=A0drivers/net/ethernet/intel/e1000e/netdev.c=C2=A0 | 10 ++--------
> =C2=A04 files changed, 9 insertions(+), 11 deletions(-)

This generates a compile issue, so I will be dropping this patch and will
await an update.
--=-YufOot3VoGvmoTFLpVHu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXl6OzAAoJEOVv75VaS+3OCEcP/20PQSB/CPNaPE2V31R666Ju
5Mo9LESDIz+NOe3uA73CjabAAi4KrrHJV8TVj9bXaL8KxzC2Ifr5nKOfhr9XIbXY
ozcluBpKjFHe8FW2j6eAj3UVw27+U6rM17I47jVfD88J1xDMD1Bg5rAxXpw+xweC
FiQ0OnmOWuV8lD4pYfXRgEsRbqYlZU9VRKzgCLG28DHI3oIm6cdqNwjRIsGVvTYo
v+3MQiS3mRXWARMLrB92WZmzYHUfjoy8QHFngur8St/1+9n1jkrQAQ/0ojuI7YrE
nrEhofaZdKJpZwFtrQBKruICrGChyzY479FqJPYvejUbuzXHs9caJshv0vSNHFKk
Lzp144fqv27lMjYfA9d8m2BhUyKSfd+Kyr69RGxRNMQXtCPpiG638mBTvPyzi+mW
K33p040+iUHFEpnoqtjeG6DKvxjjOBsGULij2BHp6log6LUEemmh3RWRbqect5qg
HSCIw8CdetiBXkjMEmdigzG42ebgwk2DT4zm6kEgOyL57mV/CDDQmKEmdZ+xOWI1
KogcQP4fEQkOoMm1VUApFh0cwP0fJGkKispMfp8CFCuC34XbPZSYViADehQHKnTA
eDDHhZVPCR8qXm0fwyRhPppp8Et73oMmqi16pHkrowbj+NPuYmeHP83GbzMvmWn2
W/CLYEzD9wQhI4Y+7MFT
=zLpo
-----END PGP SIGNATURE-----

--=-YufOot3VoGvmoTFLpVHu--
