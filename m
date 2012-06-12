From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 4/4 (v4)] stmmac: add the Energy Efficient Ethernet
 support
Date: Tue, 12 Jun 2012 16:24:56 +0200
Message-ID: <4FD75138.2090503@st.com>
References: <1339505153-26731-1-git-send-email-peppe.cavallaro@st.com> <1339505153-26731-5-git-send-email-peppe.cavallaro@st.com> <979A8436335E3744ADCD3A9F2A2B68A5027BDB@SJEXCHMB10.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"rayagond@vayavyalabs.com" <rayagond@vayavyalabs.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:55228 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751132Ab2FLOZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 10:25:21 -0400
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A5027BDB@SJEXCHMB10.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/12/2012 3:09 PM, Yuval Mintz wrote:
> Hi Giuseppe,
> 
>> @@ -1541,10 +1663,37 @@ static irqreturn_t stmmac_interrupt(int irq,
>> void *dev_id)
>> +		if (unlikely(status)) {
>> +			if (status & core_mmc_tx_irq)
>> +				priv->xstats.mmc_tx_irq_n++;
>> +			if (status & core_mmc_rx_irq)
>> +				priv->xstats.mmc_rx_irq_n++;
>> +			if (status & core_mmc_rx_csum_offload_irq)
>> +				priv->xstats.mmc_rx_csum_offload_irq_n++;
>> +			if (status & core_irq_receive_pmt_irq)
>> +				priv->xstats.irq_receive_pmt_irq_n++;
>> +
> 
> Are these EEE related?
> 
>> +	/* To handle DMA interrupts */
> 
> Is this related?
> 

To clearly manage and expose the lpi interrupt status and eee ethtool
stats I've had to do some modifications to the driver's design and I
found really useful to move other parts of the code (e.g. mmc irq stat)
in the main directly. So this just is the result of a complete reworking
made to introduce the EEE. I could better document it in the patch's
comment or create a separate patch that could take a while.

Cheers
Peppe

> 
> Cheers,
> Yuval Mintz
> 
> 
> 
