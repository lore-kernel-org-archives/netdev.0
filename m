From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: create one debugfs dir per net-device
Date: Mon, 25 May 2015 17:38:47 -0400 (EDT)
Message-ID: <20150525.173847.1648689043962348086.davem@davemloft.net>
References: <1432346609-2961-1-git-send-email-mathieu@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mathieu@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbbEYVit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 17:38:49 -0400
In-Reply-To: <1432346609-2961-1-git-send-email-mathieu@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathieu Olivari <mathieu@codeaurora.org>
Date: Fri, 22 May 2015 19:03:29 -0700

> stmmac DebugFS entries are currently global to the driver. As a result,
> having more than one stmmac device in the system creates the following
> error:
> * ERROR stmmaceth, debugfs create directory failed
> * stmmac_hw_setup: failed debugFS registration
> 
> This also results in being able to access the debugfs information for
> the first registered device only.
> 
> This patch changes the debugfs structure to have one sub-directory per
> net-device. Files under "/sys/kernel/debug/stmmaceth" will now show-up
> under /sys/kernel/debug/stmmaceth/ethN/.
> 
> Signed-off-by: Mathieu Olivari <mathieu@codeaurora.org>

Applied, thank you.
