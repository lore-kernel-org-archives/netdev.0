From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: RE: [net-next.git 4/4 (v4)] stmmac: add the Energy Efficient
 Ethernet support
Date: Tue, 12 Jun 2012 13:09:20 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A5027BDB@SJEXCHMB10.corp.ad.broadcom.com>
References: <1339505153-26731-1-git-send-email-peppe.cavallaro@st.com>
 <1339505153-26731-5-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"rayagond@vayavyalabs.com" <rayagond@vayavyalabs.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Giuseppe CAVALLARO" <peppe.cavallaro@st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1331 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751696Ab2FLNKA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 09:10:00 -0400
In-Reply-To: <1339505153-26731-5-git-send-email-peppe.cavallaro@st.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Giuseppe,

> @@ -1541,10 +1663,37 @@ static irqreturn_t stmmac_interrupt(int irq,
> void *dev_id)
> +		if (unlikely(status)) {
> +			if (status & core_mmc_tx_irq)
> +				priv->xstats.mmc_tx_irq_n++;
> +			if (status & core_mmc_rx_irq)
> +				priv->xstats.mmc_rx_irq_n++;
> +			if (status & core_mmc_rx_csum_offload_irq)
> +				priv->xstats.mmc_rx_csum_offload_irq_n++;
> +			if (status & core_irq_receive_pmt_irq)
> +				priv->xstats.irq_receive_pmt_irq_n++;
> +

Are these EEE related?

> +	/* To handle DMA interrupts */

Is this related?


Cheers,
Yuval Mintz
