From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH 1/7] net: mv643xx_eth: Simplify mv643xx_eth_adjust_link()
Date: Tue, 6 May 2014 13:17:17 -0300
Message-ID: <20140506161717.GA24264@arch.cereza>
References: <1399141622-30654-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1399141622-30654-2-git-send-email-ezequiel.garcia@free-electrons.com>
 <20140505.154004.1134814253503467382.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	w@1wt.eu, thomas.petazzoni@free-electrons.com,
	jason@lakedaemon.net, gregory.clement@free-electrons.com,
	sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
	tawfik@marvell.com, alior@marvell.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:52823 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753810AbaEFQRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 12:17:51 -0400
Content-Disposition: inline
In-Reply-To: <20140505.154004.1134814253503467382.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05 May 03:40 PM, David Miller wrote:
> From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
> Date: Sat,  3 May 2014 15:26:56 -0300
>=20
> > Currently, mv643xx_eth_adjust_link() is only used to call mv643xx_a=
djust_pscr().
> > This commit renames the latter to the former, and therefore removes=
 the extra
> > and useless function.
> >=20
> > Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
> > ---
> >  drivers/net/ethernet/marvell/mv643xx_eth.c | 15 +++++----------
> >  1 file changed, 5 insertions(+), 10 deletions(-)
> >=20
> > diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/n=
et/ethernet/marvell/mv643xx_eth.c
> > index b7b8d74..1e63c63 100644
> > --- a/drivers/net/ethernet/marvell/mv643xx_eth.c
> > +++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
> > @@ -1010,8 +1010,10 @@ static void txq_set_fixed_prio_mode(struct t=
x_queue *txq)
> > =20
> > =20
> >  /* mii management interface **************************************=
***********/
> > -static void mv643xx_adjust_pscr(struct mv643xx_eth_private *mp)
> > +static void mv643xx_eth_adjust_link(struct net_device *dev)
> >  {
> > +	struct mv643xx_eth_private *mp =3D netdev_priv(dev);
> > +
> >  	u32 pscr =3D rdlp(mp, PORT_SERIAL_CONTROL);
> >  	u32 autoneg_disable =3D FORCE_LINK_PASS |
> >  	             DISABLE_AUTO_NEG_SPEED_GMII |
>=20
> Please do not add empty lines in the middle of the function local var=
iable declarations.

Argh, I missed this.

Thanks for the catch,
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
