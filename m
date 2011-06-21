From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH RFC] igb: Fix false positive return of
 igb_get_auto_rd_done for 82580
Date: Tue, 21 Jun 2011 14:17:26 -0700
Message-ID: <1308691047.22851.60.camel@jtkirshe-mobl>
References: <1308682969-20690-1-git-send-email-guenter.roeck@ericsson.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-Jrad8Rl9wEb6ErmpG6ZA"
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tong Ho <tong.ho@ericsson.com>
To: Guenter Roeck <guenter.roeck@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57588 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752396Ab1FUVR1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 17:17:27 -0400
In-Reply-To: <1308682969-20690-1-git-send-email-guenter.roeck@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Jrad8Rl9wEb6ErmpG6ZA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-06-21 at 12:02 -0700, Guenter Roeck wrote:
> From: Tong Ho <tong.ho@ericsson.com>
>=20
> 82580 re-reads the port specific portion of eeprom after port reset.
> If called immediately after a reset, igb_get_auto_rd_done() returns
> false positive because the done bit has yet to transition from 1 to 0.
>=20
> Add wrfl() immediately after resetting 82580 port or device,
> plus a 1ms delay, to avoid the problem.
>=20
> Signed-off-by: Tong Ho <tong.ho@ericsson.com>
> Signed-off-by: Guenter Roeck <guenter.roeck@ericsson.com>
> ---
> Sent as RFC since I am not entirely sure if the solution is the
> correct one
> to address the problem we are seeing. If there is a better solution,
> please
> let me know.=20

Thank you for the suggested patch.  Carolyn is the maintainer for igb
and we will look into this issue you are seeing and the suggested fix.=20

--=-Jrad8Rl9wEb6ErmpG6ZA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOAQpmAAoJECTsCADr/EWUcbkH/Ahh4pPyxggqtGseEFMIGm2X
MIdI0IV8YaJXwCQXGhHoZX/Kl8Bv1WDT2eRvzBWz4GQw+pV/hI7a+aPpGzjTLFo8
ullFbSnxk7efD/2eb0aCXUGxaNxdiiO+Y15QhK/MbUnndCIXlZsOoTxaxpn57hcV
kmW8iBQgOW8CXuqtymD3Lz+yTNh78UFmut091Rp2pAPZoOUt9PhZCYNNmpE+ExQt
lOrXIJ5HTRp/D5H9n3fxNJqyuD8R9K6JgoxlgnqUWzUHpDdPxpRb+Wd9+D7B/zYj
zTVmvK24B4Q7zkBw5dPiyCJPEfVP9Sugpxs6ALmBYO5TNSBJLJtZ14/jrmG1/GA=
=uEGN
-----END PGP SIGNATURE-----

--=-Jrad8Rl9wEb6ErmpG6ZA--

