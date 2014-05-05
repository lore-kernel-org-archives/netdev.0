From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] net: mv643xx_eth: Simplify
 mv643xx_eth_adjust_link()
Date: Mon, 05 May 2014 15:40:04 -0400 (EDT)
Message-ID: <20140505.154004.1134814253503467382.davem@davemloft.net>
References: <1399141622-30654-1-git-send-email-ezequiel.garcia@free-electrons.com>
	<1399141622-30654-2-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	w@1wt.eu, thomas.petazzoni@free-electrons.com,
	jason@lakedaemon.net, gregory.clement@free-electrons.com,
	sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
	tawfik@marvell.com, alior@marvell.com
To: ezequiel.garcia@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32831 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001AbaEETkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 15:40:07 -0400
In-Reply-To: <1399141622-30654-2-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Date: Sat,  3 May 2014 15:26:56 -0300

> Currently, mv643xx_eth_adjust_link() is only used to call mv643xx_adjust_pscr().
> This commit renames the latter to the former, and therefore removes the extra
> and useless function.
> 
> Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
> ---
>  drivers/net/ethernet/marvell/mv643xx_eth.c | 15 +++++----------
>  1 file changed, 5 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
> index b7b8d74..1e63c63 100644
> --- a/drivers/net/ethernet/marvell/mv643xx_eth.c
> +++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
> @@ -1010,8 +1010,10 @@ static void txq_set_fixed_prio_mode(struct tx_queue *txq)
>  
>  
>  /* mii management interface *************************************************/
> -static void mv643xx_adjust_pscr(struct mv643xx_eth_private *mp)
> +static void mv643xx_eth_adjust_link(struct net_device *dev)
>  {
> +	struct mv643xx_eth_private *mp = netdev_priv(dev);
> +
>  	u32 pscr = rdlp(mp, PORT_SERIAL_CONTROL);
>  	u32 autoneg_disable = FORCE_LINK_PASS |
>  	             DISABLE_AUTO_NEG_SPEED_GMII |

Please do not add empty lines in the middle of the function local variable declarations.
