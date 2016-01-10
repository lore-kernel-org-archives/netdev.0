From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] stmmac: Don't exit mdio registration when mdio
 subnode is not found in the DTS
Date: Sun, 10 Jan 2016 18:03:17 -0500 (EST)
Message-ID: <20160110.180317.1091002009651518965.davem@davemloft.net>
References: <1452197608-29060-1-git-send-email-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-rockchip@lists.infradead.org
To: romain.perier@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58843 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756722AbcAJXDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 18:03:19 -0500
In-Reply-To: <1452197608-29060-1-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Romain Perier <romain.perier@gmail.com>
Date: Thu,  7 Jan 2016 21:13:28 +0100

> Originally, most of the platforms using this driver did not define an mdio subnode
> in the devicetree. Commit e34d65 ("stmmac: create of compatible mdio bus for stmmac driver")
> introduced a backward compatibily issue by using of_mdiobus_register explicitly
> with an mdio subnode. This patch fixes the issue by calling the function
> mdiobus_register, when mdio subnode is not found. The driver is now compatible
> with both modes.
> 
> Fixes: e34d65696d2e ("stmmac: create of compatible mdio bus for stmmac driver")
> Signed-off-by: Romain Perier <romain.perier@gmail.com>

Applied, thanks.
