From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: mask mmc interrupts
Date: Mon, 21 Nov 2011 15:31:25 -0500 (EST)
Message-ID: <20111121.153125.2199020574650123376.davem@davemloft.net>
References: <1321628420-29637-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40610 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132Ab1KUUba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 15:31:30 -0500
In-Reply-To: <1321628420-29637-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Fri, 18 Nov 2011 16:00:20 +0100

> We need to mask the MMC irq otherwise if we raise the mmc
> interrupts that are not handled the driver loops in the
> handler.
> In fact, by default all mmc counters (only used for stats)
> are managed in SW and registers are cleared on each READ.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied, thanks.
