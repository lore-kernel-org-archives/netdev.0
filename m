From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] stmmac: socfpga: remove extra call to
 socfpga_dwmac_setup
Date: Sat, 16 Apr 2016 21:48:02 -0400 (EDT)
Message-ID: <20160416.214802.155940054393750183.davem@davemloft.net>
References: <1460684549-9549-1-git-send-email-dinguyen@opensource.altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, dinh.linux@gmail.com,
	mgerlach@opensource.altera.com, netdev@vger.kernel.org
To: dinguyen@opensource.altera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37569 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751960AbcDQBsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 21:48:11 -0400
In-Reply-To: <1460684549-9549-1-git-send-email-dinguyen@opensource.altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <dinguyen@opensource.altera.com>
Date: Thu, 14 Apr 2016 20:42:29 -0500

> From: Dinh Nguyen <dinguyen@opensource.altera.com>
> 
> In the socfpga_dwmac_probe function, we have a call to socfpga_dwmac_setup,
> which is already called from socfpga_dwmac_init later in the probe function.
> Remove this extra call to socfpga_dwmac_setup.
> 
> Also we should not be calling socfpga_dwmac_setup() directly without wrapping
> it around the proper reset assert/deasserts. That is because the
> socfpga_dwmac_setup() is setting up PHY modes in the system manager, and it
> is requires the EMAC's to be in reset during the PHY setup.
> 
> Reported-by: Matthew Gerlach <mgerlach@opensource.altera.com>
> Signed-off-by: Dinh Nguyen <dinguyen@opensource.altera.com>

Applied, thank you.
