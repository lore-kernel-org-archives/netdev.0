From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igb: Indicate failure on vf reset for empty mac address
Date: Wed, 08 Oct 2014 14:29:25 -0700
Message-ID: <1412803765.2260.3.camel@jtkirshe-mobl.jf.intel.com>
References: <1412803407-10621-1-git-send-email-agraf@suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-tPeGC/NYW2x/i+B2JdUG"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mitch Williams <mitch.a.williams@intel.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Stefan Assmann <sassmann@kpanic.de>,
	Aaron Brown <aaron.f.brown@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: Alexander Graf <agraf@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33890 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755435AbaJHV3y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2014 17:29:54 -0400
In-Reply-To: <1412803407-10621-1-git-send-email-agraf@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-tPeGC/NYW2x/i+B2JdUG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-10-08 at 23:23 +0200, Alexander Graf wrote:
> Commit 5ac6f91d changed the igb driver to expose a zero (empty) mac
> address to the VF on reset rather than a random one.
>=20
> However, that behavioral change also requires igbvf driver changes
> which can be hard especially when we want to talk to proprietary
> guest OSs.
>=20
> Looking at the code previous to the commit in Linux that made igbvf
> work with empty mac addresses (8d56b6d), we can see that on reset
> failure the driver will try to generate a new mac address with both
> the old and the new code.
>=20
> Furthermore, ixgbe does send reset failure when it detects an empty
> mac address (35055928c).
>=20
> So I think it's safe to make igb behave the same. With this patch I
> can successfully run a Windows 8.1 guest with an empty mac address
> and an assigned igbvf device that has no mac address set by the host.
>=20
> If anyone is aware of a guest driver that chokes on NACK returns of
> VF RESET commands, please speak up.
>=20
> Signed-off-by: Alexander Graf <agraf@suse.de>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)

Thanks Alexander, I will add your patch to my queue.

--=-tPeGC/NYW2x/i+B2JdUG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUNay1AAoJEOVv75VaS+3O+LMP/AsjiTf7U7OQngFQZp6U4Zgd
aO4ku9HTc8SmiT+QN97YyvEUebgLzqtEJCK9X90olfRub4hPkyHUx0uByXpaZx/A
ei2jL4B2rd4scFuStbwJdZN+LBohc5Gzw9K07g5CFjnkOqoBH9WFrELIr2Wp4lxQ
mXlIunJEn7cFqvPV7G2SNxQSjABj4Qf5IIJg7SSGHSCj8XQ+vYkW1F6LW4GY7+PL
ZfK28nfibjwVJgvQpX4fwQ7+wils37u811f2ypkcSgKyNii7RjOvxwU4gMFSIbgT
SYulkxPio+zDpR2H1Vd+qxwie3w0GnnH5xx20qpOWTYwUshx16e6Der/4aRCg7Ng
YqAQ1SKphNoKj7KWLlwBjwst3WAXvscYL0Rzl4WJMfiJLD0Ah8Yj8kqYOUYMe4lH
9PxEi2pPH0gejQkp4vytx1VCnQn1A8S7y+0sqwQPoJ+S6l9Ll9f7qEMLPvm7f6Ql
TYqdl3RUWBg43j/xpsJZtfdLEtbgO/ulNIgUERz9NM6HaHZuqcv4/8M4SqdR6VkD
ARNysOQ79Q/e4rqeQgP30FiBUsQSACDle9lq0KA0TzxAcbRwpCh4AEGP/k5iCRdX
mCgyMfTzHv4JDXCJwnSysTBk1EZm13lNiKntRkZZdZ3r9BiNV4UfCKrTBwa4aqxZ
krV+Ovlx46RkbaE+ma7X
=x8QM
-----END PGP SIGNATURE-----

--=-tPeGC/NYW2x/i+B2JdUG--
