From: Don Fry <pcnet32@frontier.com>
Subject: Re: [PATCH net-next 02/14] ethernet: Use eth_<foo>_addr instead of
 memset
Date: Wed, 04 Mar 2015 21:39:01 -0800
Message-ID: <1425533941.22905.45.camel@Lunix2.home>
References: <cover.1425354527.git.joe@perches.com>
	 <86d963752051ae24a93c9a26da1e847459723aed.1425354528.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <86d963752051ae24a93c9a26da1e847459723aed.1425354528.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-03-02 at 19:54 -0800, Joe Perches wrote:
> Use the built-in function instead of memset.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Don Fry <pcnet32@frontier.com>
for pcnet32.c

> ---
>  drivers/net/ethernet/amd/pcnet32.c                  | 2 +-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 2 +-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c    | 6 +++---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c   | 2 +-
>  drivers/net/ethernet/cisco/enic/enic_main.c         | 8 ++++----
>  drivers/net/ethernet/emulex/benet/be_cmds.c         | 2 +-
>  drivers/net/ethernet/emulex/benet/be_main.c         | 2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c       | 4 ++--
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c      | 4 ++--
>  drivers/net/ethernet/mellanox/mlx4/en_selftest.c    | 2 +-
>  drivers/net/ethernet/micrel/ksz884x.c               | 2 +-
>  drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c  | 2 +-
>  drivers/net/ethernet/qlogic/qlge/qlge_main.c        | 2 +-
>  drivers/net/ethernet/smsc/smsc911x.c                | 2 +-
>  drivers/net/ethernet/ti/netcp_core.c                | 2 +-
>  drivers/net/ethernet/toshiba/ps3_gelic_wireless.c   | 4 ++--
>  drivers/net/ethernet/xscale/ixp4xx_eth.c            | 2 +-
>  17 files changed, 25 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
> index 11d6e65..8eb37e0 100644
> --- a/drivers/net/ethernet/amd/pcnet32.c
> +++ b/drivers/net/ethernet/amd/pcnet32.c
> @@ -1708,7 +1708,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
>  
>  	/* if the ethernet address is not valid, force to 00:00:00:00:00:00 */
>  	if (!is_valid_ether_addr(dev->dev_addr))
> -		memset(dev->dev_addr, 0, ETH_ALEN);
> +		eth_zero_addr(dev->dev_addr);
>  
>  	if (pcnet32_debug & NETIF_MSG_PROBE) {
>  		pr_cont(" %pM", dev->dev_addr);
