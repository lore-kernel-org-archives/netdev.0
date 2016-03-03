From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: Fix 'eth0: No PHY found' regression
Date: Thu, 03 Mar 2016 15:02:26 -0500 (EST)
Message-ID: <20160303.150226.2220500775627145225.davem@davemloft.net>
References: <1456762702-23713-1-git-send-email-gabriel.fernandez@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, preid@electromag.com.au,
	manabian@gmail.com, vbridger@opensource.altera.com,
	mathieu@codeaurora.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, alexandre.torgue@st.com,
	maxime.coquelin@st.com
To: gabriel.fernandez@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46730 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbcCCUCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 15:02:31 -0500
In-Reply-To: <1456762702-23713-1-git-send-email-gabriel.fernandez@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gabriel Fernandez <gabriel.fernandez@linaro.org>
Date: Mon, 29 Feb 2016 17:18:22 +0100

> This patch manages the case when you have an Ethernet MAC with
> a "fixed link", and not connected to a normal MDIO-managed PHY device.
> 
> The test of phy_bus_name was not helpful because it was never affected
> and replaced by the mdio test node.
> 
> Signed-off-by: Gabriel Fernandez <gabriel.fernandez@linaro.org>

Applied to 'net', thanks.
