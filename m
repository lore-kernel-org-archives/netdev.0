From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v1 2/4] stmmac: pci: TX and RX queue priority
 configuration
Date: Mon, 8 May 2017 15:18:26 +0100
Message-ID: <9ca48adc-03b2-1a99-3cd1-d9dc3b46d904@synopsys.com>
References: <20170508141422.39612-1-andriy.shevchenko@linux.intel.com>
 <20170508141422.39612-3-andriy.shevchenko@linux.intel.com>
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
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:39175 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754652AbdEHOSa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 10:18:30 -0400
In-Reply-To: <20170508141422.39612-3-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 3:14 PM de 5/8/2017, Andy Shevchenko escreveu:
> The commit a8f5102af2a7
> 
> 	("net: stmmac: TX and RX queue priority configuration")
> 
> missed Intel Quark configuration. Append it here.
> 
> Fixes: a8f5102af2a7 ("net: stmmac: TX and RX queue priority configuration")
> Cc: Joao Pinto <Joao.Pinto@synopsys.com>
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> index ae3e836f9bb6..c015a715a8ac 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> @@ -149,6 +149,10 @@ static int quark_default_data(struct plat_stmmacenet_data *plat,
>  	plat->tx_queues_to_use = 1;
>  	plat->rx_queues_to_use = 1;
>  
> +	/* Disable Priority config by default */
> +	plat->tx_queues_cfg[0].use_prio = false;
> +	plat->rx_queues_cfg[0].use_prio = false;
> +
>  	return 0;
>  }
>  
> 

Acked-by: Joao Pinto <jpinto@synopsys.com>
