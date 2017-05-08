From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH v1 1/4] stmmac: pci: set default number of rx and tx
 queues
Date: Mon, 8 May 2017 16:22:29 +0200
Message-ID: <6b20af33-3790-dddb-8474-cb0d910524fe@st.com>
References: <20170508141422.39612-1-andriy.shevchenko@linux.intel.com>
 <20170508141422.39612-2-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Jan Kiszka <jan.kiszka@siemens.com>,
        netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:33758 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751326AbdEHOWp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 10:22:45 -0400
In-Reply-To: <20170508141422.39612-2-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/8/2017 4:14 PM, Andy Shevchenko wrote:
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
>   drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 4 ++++
>   1 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> index 39be96779145..ae3e836f9bb6 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> @@ -145,6 +145,10 @@ static int quark_default_data(struct plat_stmmacenet_data *plat,
>   	/* Set the maxmtu to a default of JUMBO_LEN */
>   	plat->maxmtu = JUMBO_LEN;
>   
> +	/* Set default number of RX and TX queues to use */
> +	plat->tx_queues_to_use = 1;
> +	plat->rx_queues_to_use = 1;
> +
>   	return 0;
>   }
>   

For the Series, please consider my

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>


thx a lot
