From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFT PATCH v3 00/12] Cleanup and extension of netdev features
Date: Fri, 26 Aug 2011 16:17:06 -0700
Message-ID: <1314400627.12377.12.camel@jtkirshe-mobl>
References: <cover.1308758435.git.mirq-linux@rere.qmqm.pl>
	 <4E569CC8.9040605@candelatech.com> <20110826184155.GA14744@rere.qmqm.pl>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-yFUe0Xm7jfAkKgWGNFYM"
Cc: Ben Greear <greearb@candelatech.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46350 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752936Ab1HZXRH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Aug 2011 19:17:07 -0400
In-Reply-To: <20110826184155.GA14744@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-yFUe0Xm7jfAkKgWGNFYM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-08-26 at 11:41 -0700, Micha=C5=82 Miros=C5=82aw wrote:
> On Thu, Aug 25, 2011 at 12:04:40PM -0700, Ben Greear wrote:
> > On 06/22/2011 09:04 AM, Micha=C5=82 Miros=C5=82aw wrote:
> > >v3 of a feature handling cleanup and extension series. For testing, yo=
u
> > >might want user-space ethtool patched with:
> > >http://patchwork.ozlabs.org/patch/96374/
> > It looks like this is not in net-next yet...any hope of this
> > going in soon?
>=20
> It's because the series depends on finishing conversions of all drivers
> to ndo_fix/set_features. e1000e, igbvf, ixgb, ixgbevf are pending.
>=20
> BTW, Jeff, what is the status of those conversions? Last version of ixgbe
> patch from Donald Skidmore (sent about a month ago) was mostly ready IIUC=
.
>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw

e1000e patch just completed testing, I will be pushing that tonight.
ixgbe got pushed back in June, but there some suggested changes you had
made with Don and that patch has been in/out of testing due to issues
found. =20

It also appears that the ixgbevf patch has completed testing.  The only
remaining patch which is left to complete is igbvf.

--=-yFUe0Xm7jfAkKgWGNFYM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOWClyAAoJECTsCADr/EWUaCYIAKVnY2QRqAqZygqsMysy9vEi
/n3dyxrI7B2/H0JreI6JegTurQAxL6M/njSzCKNzU/b6jbwvNs2Ymht3b3ma9Utg
28BUEeSIjvZa9KhxRDsBK23ygjcQQKLP6HxqnhYcXMANZpeVWTR0e4sZR5Ce7lyQ
K/sJhMnXrI6cgk97DxLg8IBx2G2ZtNYm5e1FWmWzjS8mlICl9a9/8Yl59orp5kuB
dmcum+Qcbh+yq9bjbXYSPDNN5seFvZ5EpWynF4TbOjRfVyJGp07Teh/+HFVvV8Rn
EQLblIqilw+/loo+bG3VAoS+eE/Rs6GHPXL8NcetKy0W3rWAVwiDDCoyjegu+2I=
=ESEd
-----END PGP SIGNATURE-----

--=-yFUe0Xm7jfAkKgWGNFYM--
