From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 2/2] e100: enable transmit time stamping.
Date: Wed, 04 Apr 2012 02:04:43 -0700
Message-ID: <1333530283.3046.14.camel@jtkirshe-mobl>
References: <cover.1331400160.git.richardcochran@gmail.com>
	 <33c61d135f4fd62e5128466633302414ead0092e.1331400160.git.richardcochran@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-quEyQbc6wrwJkF9o6pmu"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:43758 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753471Ab2DDJE6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 05:04:58 -0400
In-Reply-To: <33c61d135f4fd62e5128466633302414ead0092e.1331400160.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-quEyQbc6wrwJkF9o6pmu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2012-03-10 at 09:29 -0800, Richard Cochran wrote:
> This patch enables software (and phy device) transmit time stamping.
> Tested on an old PIII laptop with built in NIC.
>=20
> Cc: Alex Duyck <alexander.h.duyck@intel.com>
> Cc: Bruce Allan <bruce.w.allan@intel.com>
> Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Cc: Don Skidmore <donald.c.skidmore@intel.com>
> Cc: Greg Rose <gregory.v.rose@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: John Ronciak <john.ronciak@intel.com>
> Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
>=20
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---
>  drivers/net/ethernet/intel/e100.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)=20

Richard-

I had this patch in my queue, but during testing we found some serious
issues with some adapters.  With every 82559 based adapter Aaron tried
the system would panic on driver load.  This included at least one
sampling of D101S and D101M.  Every other e100 chipset Aaron tried
(82557, 82558, 82550) appeared to work fine.

So I am dropping this patch as is due to the kernel panics.

Cheers,
Jeff

--=-quEyQbc6wrwJkF9o6pmu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPfA6rAAoJEOVv75VaS+3O7SYP/imUaB3pZGGemcxuJ+7S2UFT
VT4b9JRRLwPm33dMRbhMGS33AaErDLa5PEzjC1P/OS97ObdBqMZarrah9R4sOoJh
3bCoHoMkUPqX9DKKGULOLphKzU4ARuTIe/1L+obftqqzcZK6M9RHwqK6wWExo/lo
+IcbRPzd0nU7NobRhgKCAauztfv/s9yzrAbLcGBYXilz2FwIsq0h6+JFqw/3VD6Z
c5UExUjBUX8CMBeUIXTos4TnPzdfwjToYpO5USoW/tLQEBTrx3GJjPUGbzxv7yVt
tkO1eDzXqqVF8rr2g0MMfoyR+E+Llm8Zs26pSm71MVuAgZhzeQP02ApZAs086wK0
TJSQqcmmKfOeU78DJNk2s8M1mvfcCQ0Q8lb0K/V0DS0oG4sHO4EEfUlJvYS7Dm/2
qrbwA3nlFXPAnjoGo1Le3iTuIcWgAhlcFaN0HvzL15UJv55qdaQReio+PXl3LRg/
rga6yGnDUkKNeBf21tvr2vQI+AXqtEYksgNs8J83ij4wh+d9LHsbRkISaXuuwwX1
zdZbl/6JOgNfMGB/DdcRUweVz742+PeuBcwWPYQJrnCQGoA3hao2Xd9XDvWJ40or
ilKjdhM9bB35lsbnvzT1GkYrcXBDUAre+9d5i9sPPw4DtbWmqQnYELdEv3jtOlQ4
xeElp582vxUVcqqC2xoM
=k9gw
-----END PGP SIGNATURE-----

--=-quEyQbc6wrwJkF9o6pmu--
