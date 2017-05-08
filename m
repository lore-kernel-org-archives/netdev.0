From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v1 3/4] stmmac: pci: RX queue routing configuration
Date: Mon, 8 May 2017 15:18:34 +0100
Message-ID: <fcac9359-0f10-e77a-f6e6-d4b85ff56a25@synopsys.com>
References: <20170508141422.39612-1-andriy.shevchenko@linux.intel.com>
 <20170508141422.39612-4-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Jan Kiszka <jan.kiszka@siemens.com>,
        netdev <netdev@vger.kernel.org>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.47.9]:55044 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754652AbdEHOSj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 10:18:39 -0400
In-Reply-To: <20170508141422.39612-4-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 3:14 PM de 5/8/2017, Andy Shevchenko escreveu:
> The commit abe80fdc6ee6
> 
>     ("net: stmmac: RX queue routing configuration")
> 
> missed Intel Quark configuration. Append it here.
> 
> Fixes: abe80fdc6ee6 ("net: stmmac: RX queue routing configuration")
> Cc: Joao Pinto <Joao.Pinto@synopsys.com>
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> index c015a715a8ac..2456e0a945ef 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> @@ -153,6 +153,9 @@ static int quark_default_data(struct plat_stmmacenet_data *plat,
>  	plat->tx_queues_cfg[0].use_prio = false;
>  	plat->rx_queues_cfg[0].use_prio = false;
>  
> +	/* Disable RX queues routing by default */
> +	plat->rx_queues_cfg[0].pkt_route = 0x0;
> +
>  	return 0;
>  }
>  
> 

Acked-by: Joao Pinto <jpinto@synopsys.com>
