From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH Kernel-3.1.0] mdio-gpio: Add reset functionality to
 mdio-gpio driver.
Date: Tue, 15 Nov 2011 16:56:42 -0500 (EST)
Message-ID: <20111115.165642.630874364956113809.davem@davemloft.net>
References: <1320845931-25782-1-git-send-email-srinivas.kandagatla@st.com>
	<20111114.144222.2216968580935980384.davem@davemloft.net>
	<4EC25608.8070308@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stuart.menefy@st.com
To: srinivas.kandagatla@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217Ab1KOV4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 16:56:51 -0500
In-Reply-To: <4EC25608.8070308@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Date: Tue, 15 Nov 2011 12:07:36 +0000

> Subject: [PATCH Kernel-3.1.0] mdio-gpio: Add reset functionality to mdio-gpio driver(v2).
> 
> This patch adds phy reset functionality to mdio-gpio driver. Now
> mdio_gpio_platform_data has new member as function pointer which can be
> filled at the bsp level for a callback from phy infrastructure. Also the
> mdio-bitbang driver fills-in the reset function of mii_bus structure.
> 
> Without this patch the bsp level code has to takecare of the reseting
> PHY's on the bus, which become bit hacky for every bsp and
> phy-infrastructure is ignored aswell.
> 
> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>

Applied.
