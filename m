From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000e: Do not allow CRC stripping to be disabled on
 82579 w/ jumbo frames
Date: Wed, 08 Apr 2015 19:58:22 -0700
Message-ID: <1428548302.2729.9.camel@jtkirshe-mobl>
References: <20150409013554.3231.10427.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-rbso194E/Z2gTki3Gl6K"
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	Yanir Lubetkin <yanirx.lubetkin@intel.com>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:18590 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754254AbbDIC6X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 22:58:23 -0400
In-Reply-To: <20150409013554.3231.10427.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-rbso194E/Z2gTki3Gl6K
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-04-08 at 18:37 -0700, Alexander Duyck wrote:
> The driver wasn't allowing jumbo frames to be enabled when CRC
> stripping
> was disabled, however it was allowing CRC stripping to be disabled
> while
> jumbo frames were enabled.  This fixes that by making it so that the
> NETIF_F_RXFCS flag cannot be set when jumbo frames are enabled on
> 82579 and
> newer parts.
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c |   14 ++++++++++++++
>  1 file changed, 14 insertions(+)

Thanks Alex, I will add your patch to my queue.
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-rbso194E/Z2gTki3Gl6K
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVJerOAAoJEOVv75VaS+3O2RAP/jfNV/mQkKc4q/dEpLNX3Lli
Hrpay+28Bs2sSiiLNm4XnYKrlrih7nuFdM8IPKWz+uI8QGYplMrLKuQwX50pLbWR
IySydqckuiP6RkT9F5RLmS2wb9DxXKcURB9iUEqLLY0OEYCufbpEYLH/weMIEzhs
AwGAgGgudKAX3LGfIYMAt/0NNhvL/rS8JK17pVu2lS7vPWhjh1XJiUCpIQIhTh3V
Ew05YAVD0nkPGCDB4Pz3e95gwVYOkZQkghJ8ys0aq2l20EpImzb+Mg2ZhxKavWcI
F8XJR2abHi7ZdIrjJmICgbtY762SZBC+s7BxOXyvmcw3zQPO8iKojAEvJhj3gBrE
pdGCAdPDyjzDVasVyVaRXmH+etyPNEY5U0qkbTFt3uQ5eyHww7D8cKfub3bYTeeA
yfF4KH5dCdRzQFUf4A0iCMOJTwQi6pHdOVM1CSPxB+f28oDn5HgDaucH3MeYc6hl
VrBeSQ3Rww2T9m+YobuaY3/BM5TaKRYB6hG5b6EfOdIj4LSUjKo8HC4KWSGpJ4fy
C0dBfbHeX3wDKP/thyD4doxulg3voA58YQrMfa+7qcIZOff9CYkHybXwZlpGkvnB
lEalpmfJnte8aVbfGoExYNXksykMKfMmkoepwh8frKzGqJd2gwWkXgMhPGwVKVcO
P1zfM12G3gwDa0VQb2fg
=Dy9M
-----END PGP SIGNATURE-----

--=-rbso194E/Z2gTki3Gl6K--
