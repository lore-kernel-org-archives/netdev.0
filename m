From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: add drop transmit status feature
Date: Tue, 11 Apr 2017 14:53:05 -0400 (EDT)
Message-ID: <20170411.145305.907770601077151355.davem@davemloft.net>
References: <738665b880f7c661c4108d34a9d8fc43ef2f9fa4.1491921785.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35130 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752224AbdDKSxG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 14:53:06 -0400
In-Reply-To: <738665b880f7c661c4108d34a9d8fc43ef2f9fa4.1491921785.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Tue, 11 Apr 2017 15:44:10 +0100

> +static void dwmac4_enable_tx_drop(struct mac_device_info *hw)
> +{
> +	void __iomem *ioaddr = hw->pcsr;
> +	u32 value = readl(ioaddr + MTL_OPERATION_MODE);
> +
> +	value &= ~MTL_OPERATION_DTXSTS;
> +	value |= MTL_OPERATION_DTXSTS;

I think the mask is unnecessary, just simply set the bit.
