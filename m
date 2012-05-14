From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 3/3] stmmac: fix suspend/resume locking
Date: Mon, 14 May 2012 18:54:08 -0400 (EDT)
Message-ID: <20120514.185408.879679325124225805.davem@davemloft.net>
References: <1336983523-4075-1-git-send-email-peppe.cavallaro@st.com>
	<1336983523-4075-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60355 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758162Ab2ENWyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 18:54:13 -0400
In-Reply-To: <1336983523-4075-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon, 14 May 2012 10:18:43 +0200

> Upon resume from standby, there is a possible interrupt
> unsafe locking scenario raised when configure the Kernel
> with CONFIG_PROVE_LOCKING. So this patch fixes that in
> PM driver stuff by calling lock/unlock_irqsave/restore.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
