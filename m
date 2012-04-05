From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 2/2] ixgbe: add missing rtnl_lock in PM resume path
Date: Thu, 05 Apr 2012 16:03:11 -0700
Message-ID: <1333666991.2567.19.camel@jtkirshe-mobl>
References: <1333638664-17062-1-git-send-email-bpoirier@suse.de>
	 <1333638664-17062-2-git-send-email-bpoirier@suse.de>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-QObKXCRu2TLoDvU+SH1l"
Cc: Alex Duyck <alexander.h.duyck@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333638664-17062-2-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-QObKXCRu2TLoDvU+SH1l
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-04-05 at 11:11 -0400, Benjamin Poirier wrote:
> Upon resume from standby, ixgbe may trigger the ASSERT_RTNL() in
> netif_set_real_num_tx_queues(). The call stack is:
>         netif_set_real_num_tx_queues
>         ixgbe_set_num_queues
>         ixgbe_init_interrupt_scheme
>         ixgbe_resume
>=20
> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
>=20
> ---
> Unlike patch 1 for igb, we cannot lock rtnl closer to the point where
> netif_set_real_num_tx_queues() is called because
> ixgbe_init_interrupt_scheme()
> is also called by the dcb code, already under rtnl.
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)=20

Thanks Benjamin, I will add the patch to my igb queue of patches.

--=-QObKXCRu2TLoDvU+SH1l
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPfiSvAAoJEOVv75VaS+3OjtAP/0lEerebAsNk6txLYd3vsYWS
mbY9VDY6iAuEUeueoArNCSxMiHQVFu+dutpq5TAzXUd7QIX+8KQExB90R/9sVhUv
3vcZGCfe5WWTFh8nK0RLvXUeHQEFB4om4dY+/6HZ5AnhX+fDBdn3CJrwpCwwDJei
Pn3SfnUJfPCfbkQ+9madKmW37t8FtTfzFUlpYA+lwEengAXMXpCB6915/QAe+QzM
EXskZ5rzBqdDXLVx3wehV4M8eNMqxV7ESXW6ay8tl61Hvhp6aBt+MYQoiywZCOBi
zZ5WClSKNJ1bBwOCOXLGBh/zMd7ThjsH8TNzp2mGlgP48N6iFlrPJmMYhyLRuG2g
u5WBbwrJLQrqFVHEbIAvLs5p7UvWBBpksetmOjvPwd78y6LaHcXQ4V2C2CIHdx42
M8SL0n4rswvKPLh6XSJcvkYOBstEss1Jl2ncUJ6G4wvrvfgRXZ27KVaFihaLTEDW
O+S7u+ftDrSHXiZaQ8BzxWzlHyHzf6dYAy/ib4k5FB15su/bBtddKkPgPseN9zfo
QUtIeKpDF7ELoyGuE+9CBVmyc/3xBFwXdXcdayzg5Cfx3sMCmDucyx2OtRsaHXnM
rmd/HOIBWe7isD2vrA+Wu6YU6AVkbgDIGH1UIREezU9T8dcCthghIT9X53SI65+d
0RX5ly/kPZawkgeEHu7x
=cuiC
-----END PGP SIGNATURE-----

--=-QObKXCRu2TLoDvU+SH1l--
