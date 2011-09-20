From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 01/11] ixgb: convert to ndo_fix_features
Date: Mon, 19 Sep 2011 17:02:47 -0700
Message-ID: <1316476968.2184.14.camel@jtkirshe-mobl>
References: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1316225752-1709-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110917132153.GA32572@rere.qmqm.pl>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-QZGW+hTT5yR1g3yLQnPy"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:6286 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751974Ab1ITACt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Sep 2011 20:02:49 -0400
In-Reply-To: <20110917132153.GA32572@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-QZGW+hTT5yR1g3yLQnPy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2011-09-17 at 06:21 -0700, Micha=C5=82 Miros=C5=82aw wrote:
> On Fri, Sep 16, 2011 at 07:15:42PM -0700, Jeff Kirsher wrote:
> > From: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> > Private rx_csum flags are now duplicate of netdev->features &
> NETIF_F_RXCSUM.
> > Removing this needs deeper surgery.
> [...]
>=20
> Hmm. Looks like this patch is not complete: part removing
> get/set_flags
> from ethtool_ops is missing. I don't remember if this was included or
> not
> in the patch I sent originally. I'm attaching it now, rebased on
> current
> net-next (not tested).
>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw=20
>=20
> ---
>=20
> Finish conversion to unified ethtool ops: convert get_flags.
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>=20

Thanks Michal, I have added the patch to my queue.

--=-QZGW+hTT5yR1g3yLQnPy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOd9gnAAoJECTsCADr/EWUw2oIAKto4atgzI9dhkfuPkMMrSEW
0dqdBaxpro3LOs3OvILvd6e8g/jI9jVb/2BCXwh8LkPPJTGvlsnFKhf3rOdCSd1Q
q5z7NNjzxtlXkZ6JBzbVLy7tMu3utRUjBnsUNKYiB0R883iJpEggnFg9Dw1amQ/0
n4dbEsGj+BtWYLMDFDXAs0HLoSMXz7qEYP94waL6OQjW5UAHhyCwTQpxw1XrtPPv
1rD7jJzT12VpuAqA+uscMtxGVhQJ4qimzlc6oVSCnCkU/PPfLyEw02dh4fU4+svi
G+LFQ+KPt7U+xkGe06o+dTUA+UA6Ds+FErcrsBq+jMJ2bT8CtKJlJUplDgNuKmo=
=Bwxr
-----END PGP SIGNATURE-----

--=-QZGW+hTT5yR1g3yLQnPy--
