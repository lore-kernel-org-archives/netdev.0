From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 07/11] igb: Avoid uninitialized advertised variable in
 eee_set_cur
Date: Tue, 01 Oct 2013 16:10:02 -0700
Message-ID: <1380669002.2075.3.camel@jtkirshe-mobl>
References: <1380572952-30729-1-git-send-email-andi@firstfloor.org>
	 <1380572952-30729-8-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-jK6N35UU8v1y9b2fHgnT"
Cc: linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:35577 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751764Ab3JAXKE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 19:10:04 -0400
In-Reply-To: <1380572952-30729-8-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jK6N35UU8v1y9b2fHgnT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-09-30 at 13:29 -0700, Andi Kleen wrote:
> From: Andi Kleen <ak@linux.intel.com>
>=20
> eee_get_cur assumes that the output data is already zeroed. It can
> read-modify-write the advertised field:
>=20
>               if (ipcnfg & E1000_IPCNFG_EEE_100M_AN)
> 2594                    edata->advertised |=3D ADVERTISED_100baseT_Full;
>=20
> This is ok for the normal ethtool eee_get call, which always
> zeroes the input data before.
>=20
> But eee_set_cur also calls eee_get_cur and it did not zero the input
> field. Later on it then compares agsinst the field, which can contain
> partial
> stack garbage.
>=20
> Zero the input field in eee_set_cur() too.
>=20
> Cc: jeffrey.t.kirsher@intel.com
> Cc: netdev@vger.kernel.org
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_ethtool.c | 2 ++
>  1 file changed, 2 insertions(+)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-jK6N35UU8v1y9b2fHgnT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSS1ZKAAoJEOVv75VaS+3OYyMQAIYkgc2xZA9RsFOGOt0xXl6X
zO3C03G/0D3MqifW9lv9b9leroOZ46f+ZiQJBzNRGVeRIX7KwCivZZ3M4qH1ZoBW
MPMD1W1IxL5kpTuPyUmnJL7pJTdcYhAJrU6YY5xtF68kT6W2L3ukW/sWYr6E2aYG
ehtU3hgi930FgAAZdKFhkQf3udCO7CD77LiUmPA17qZC4wNaDHyadgkTJ2uJHmtd
hwKpP92q56vsMQszc7WTxy+82baM6q/VRGAd4QXGS/RH85afw2hOliuhSBl10WEx
dspL7+q2HMiwRr/I4Rhwf3e1hyG5oDYzArL3ygu1cHss6EBkJOBtaLluoZCIsryb
5xLcdamre32fbTGUAzIelYdYHz37DEdAQsL9gaOlPvyZzC6uAmJ5ZCCTcBsgIDYn
gyJal6zmVOND+TKihQ9vvzcEu+Rp+25uxueXsN8TSUW6rWmhGIFjWiOCWKkEQEed
gPNPekiNGiv7SX0bBouj/KSxebCOxRET52dr+q3FwJ0lPY3ueX4qn6XPvmWGpbJV
YQ4OV4w9mWSu5IEsFWAxfLgy4F3ZiAdtfFPVEi3pheFNqQE1EOc9qMNCCayg3lon
vMwiYAOi3mU8iSznYTOj2Sf9d+AWeaqJ6MlFK1ZB7aYI6CjqEk/++efODIs44QDA
QxweJXPFiEwPIU7UxIl8
=rVEt
-----END PGP SIGNATURE-----

--=-jK6N35UU8v1y9b2fHgnT--
