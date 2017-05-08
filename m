From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v1 1/4] stmmac: pci: set default number of rx and tx
 queues
Date: Mon, 8 May 2017 15:18:17 +0100
Message-ID: <30583383-106f-2611-ebad-8dd8ad41d434@synopsys.com>
References: <20170508141422.39612-1-andriy.shevchenko@linux.intel.com>
 <20170508141422.39612-2-andriy.shevchenko@linux.intel.com>
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
Received: from smtprelay2.synopsys.com ([198.182.60.111]:39166 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752042AbdEHOSW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 10:18:22 -0400
In-Reply-To: <20170508141422.39612-2-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 3:14 PM de 5/8/2017, Andy Shevchenko escreveu:
> The commit 26d6851fd24e
> 
> 	("net: stmmac: set default number of rx and tx queues in stmmac_pci")
> 
> missed Intel Quark configuration. Append it here.
> 
> Fixes: 26d6851fd24e ("net: stmmac: set default number of rx and tx queues in stmmac_pci")
> Cc: Joao Pinto <Joao.Pinto@synopsys.com>
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> index 39be96779145..ae3e836f9bb6 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> @@ -145,6 +145,10 @@ static int quark_default_data(struct plat_stmmacenet_data *plat,
>  	/* Set the maxmtu to a default of JUMBO_LEN */
>  	plat->maxmtu = JUMBO_LEN;
>  
> +	/* Set default number of RX and TX queues to use */
> +	plat->tx_queues_to_use = 1;
> +	plat->rx_queues_to_use = 1;
> +
>  	return 0;
>  }
>  
> 

Acked-by: Joao Pinto <jpinto@synopsys.com>
