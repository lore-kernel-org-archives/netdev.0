From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] ixgbe: fix typo
Date: Tue, 10 Jun 2008 18:22:21 -0400
Message-ID: <484EFE9D.9020807@garzik.org>
References: <20080609225658.1219.89600.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080609225658.1219.89600.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Jeff Kirsher wrote:
> Define names were accidently transposed.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/ixgbe/ixgbe_82598.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
> index 6321b05..2f38e84 100644
> --- a/drivers/net/ixgbe/ixgbe_82598.c
> +++ b/drivers/net/ixgbe/ixgbe_82598.c
> @@ -58,8 +58,8 @@ static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw);
>  
>  static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw)
>  {
> -	hw->mac.num_rx_queues = IXGBE_82598_MAX_TX_QUEUES;
> -	hw->mac.num_tx_queues = IXGBE_82598_MAX_RX_QUEUES;
> +	hw->mac.num_rx_queues = IXGBE_82598_MAX_RX_QUEUES;
> +	hw->mac.num_tx_queues = IXGBE_82598_MAX_TX_QUEUES;
>  	hw->mac.num_rx_addrs = IXGBE_82598_RAR_ENTRIES;
>  
>  	/* PHY ops are filled in by default properly for Fiber only */
> 

applied for 2.6.26



-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
