From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch -next] 6LoWPAN: double free in lowpan_fragment_xmit()
Date: Wed, 16 Nov 2011 11:32:54 +0300
Message-ID: <20111116083254.GB4349@mwanda>
References: <20111116082138.GA10264@elgon.mountain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="EuxKj2iCbKjpUGkD"
Cc: Sergey Lapin <slapin@ossfans.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:16844 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755066Ab1KPIcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 03:32:04 -0500
Content-Disposition: inline
In-Reply-To: <20111116082138.GA10264@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--EuxKj2iCbKjpUGkD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Nov 16, 2011 at 11:21:38AM +0300, Dan Carpenter wrote:
> dev_queue_xmit() consumes its own skb, so the call to dev_kfree_skb()
> ieee802154/6lowpan.clowpan_fragment_xmits a double free.
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Dur...  I messed up my commit message right before sending.  Will
resend.

regards,
dan carpenter



--EuxKj2iCbKjpUGkD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJOw3U2AAoJEOnZkXI/YHqRwEcP/36IBMZs8ZWVBFFVqKzFGBB2
wwOdOBIpVrHyI7r/5fRb7HweAwVPItQKd8Ob6JyW0S1XHqe22LkfGDz7sZyAmVzL
aMfHpX6n3uZgosSfOgMNMyI2pR3qzZD1KJKPwJgBvYmEmu4SUfJ0CiD/HE/2PVFn
qKJNsxR9adFZOil9kFxfYzCaLkBrgFYSXzeWKLY3ooQpXbqtluT56uFgDKMLo7F7
nSFfr2Y/svqhcOjtBKzRTx1CHUZj9MWPY3jYd6k5LaNHeqs7h4ex+CiqQEH2o43D
PbAxPDo/ZxusTJsIPnAeFfu7ckeJsFeGcKZjwLnzUA1vYGOjAOLv3jPvvXJOkRwF
NtSffwo5+lZrUO5mZIkzejndq+JZX0BGGrz28cdJM+hUiy5SNgns88ioZeL2oiGM
g9jDtIo8ZJNumtxEWx3eIixT0Wxn1mWrg6Wr+IJbwITvuXpQi2/AWYxGZrPu9fJN
Bca0yfP1C3isJ53Mt9P4ro4ngZzxRfIDC99NlNQJAc63Vhy7YYc5lPb3NZa4D3G5
6hLCshwcN6LN/u6/WtyPf+zthxvddaMNrYrUcMdRSka0dI0+y3zw+1V3qN9nXA3P
Uq0HQ6DtSyX5jPPpfUSXzBFYmGJEJwQ7eUpI5/CthyjDbX1EZzZ91YK3gsWgXPEq
I5TCWp6pBrCIovqu5Vsy
=WdKc
-----END PGP SIGNATURE-----

--EuxKj2iCbKjpUGkD--
