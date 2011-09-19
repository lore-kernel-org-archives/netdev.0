From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] intel: Convert <FOO>_LENGTH_OF_ADDRESS to ETH_ALEN
Date: Mon, 19 Sep 2011 16:33:15 -0700
Message-ID: <1316475196.2184.7.camel@jtkirshe-mobl>
References: <1316246677-8830-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1316246677-8830-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1316249007.1610.13.camel@Joe-Laptop> <20110919143629.00007675@unknown>
	 <1316471288.22881.3.camel@Joe-Laptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-eJ4KSj6XSAtfmhmIakzY"
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21436 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751147Ab1ISXd1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Sep 2011 19:33:27 -0400
In-Reply-To: <1316471288.22881.3.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-eJ4KSj6XSAtfmhmIakzY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-09-19 at 15:28 -0700, Joe Perches wrote:
> Use the normal #defines not module specific ones.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> Here are the other, not ixgb uses of LENGTH_OF_ADDRESS
> converted to ETH_ALEN.  Compile tested allyesconfig only.
>=20
>  drivers/net/ethernet/intel/e1000/e1000_hw.h    |    1 -
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  |    8 +++-----
>  drivers/net/ethernet/intel/ixgbevf/defines.h   |    1 -
>  drivers/net/ethernet/intel/ixgbevf/vf.c        |    4 ++--
>  5 files changed, 6 insertions(+), 10 deletions(-)=20

Thanks Joe.  I have added the patch to my queue.

--=-eJ4KSj6XSAtfmhmIakzY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOd9E7AAoJECTsCADr/EWUEn4IAITHhduL9hK6tmR9Fygjoa5r
STo2slQ04AK0TVL0BtYRe9axYglKOLhdvupmu23KubvbFOLzqucaHEG5x6xJ5hUl
nhxvY8skBqazka1cSMaEkYvLOywII9JARRwAdZJ6bYcUnEVmQvpUGjGYW2tdOLWb
oisG0rhHsud/7mBSxOsZc/hbY8VZhpUb0QqKRsVUU+4bnaff08shyHecIbfB8wcu
R8RvxtFnqt7NyT/cCUpxDzAfCNCiiymF5r9qaIaco42mOPFL/yEcRtQsN5/JiQzB
751lgxS8nLyuz2wTXrBDcJ79WmivanhhGmFPOKK25b21w9/wKoyd5yYRmJJis9U=
=ZWdl
-----END PGP SIGNATURE-----

--=-eJ4KSj6XSAtfmhmIakzY--
