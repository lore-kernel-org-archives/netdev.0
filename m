From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V5 1/1] net: ethernet: Add TSE PCS support to
 dwmac-socfpga
Date: Tue, 28 Jun 2016 05:48:15 -0400 (EDT)
Message-ID: <20160628.054815.1440008157228833144.davem@davemloft.net>
References: <1466759603-30769-1-git-send-email-thloh@altera.com>
	<20160628.053450.2071467949973087029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, mark.rutland@arm.com, peppe.cavallaro@st.com,
	alexandre.torgue@st.com, preid@electromag.com.au,
	dinguyen@opensource.altera.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	thloh85@gmail.com, cnphoon@altera.com
To: thloh@altera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509AbcF1Jsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 05:48:46 -0400
In-Reply-To: <20160628.053450.2071467949973087029.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 28 Jun 2016 05:34:50 -0400 (EDT)

> From: <thloh@altera.com>
> Date: Fri, 24 Jun 2016 02:13:23 -0700
> 
>> From: Tien Hock Loh <thloh@altera.com>
>> 
>> This adds support for TSE PCS that uses SGMII adapter when the phy-mode of
>> the dwmac is set to sgmii.
>> 
>> Signed-off-by: Tien Hock Loh <thloh@altera.com>
>> Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> Acked-by: Rob Herring <robh@kernel.org>
> 
> Applied to net-next, thanks.

I had to revert, this breaks the build:

ERROR: "tse_pcs_fix_mac_speed" [drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.ko] undefined!
ERROR: "tse_pcs_init" [drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.ko] undefined!
