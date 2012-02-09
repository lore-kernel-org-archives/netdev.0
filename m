From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] stmmac: request_irq when use an ext wake irq line
Date: Thu, 09 Feb 2012 14:02:51 -0500 (EST)
Message-ID: <20120209.140251.1155907203355431647.davem@davemloft.net>
References: <1328774114-28894-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, francesco.virlinzi@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57375 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758265Ab2BITC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 14:02:59 -0500
In-Reply-To: <1328774114-28894-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu,  9 Feb 2012 08:55:13 +0100

> From: Francesco Virlinzi <francesco.virlinzi@st.com>
> 
> In case of we use an external Wake-Up IRQ line
> (priv->wol_irq != dev->irq) we need to invoke the
> request_irq.
> 
> Signed-off-by: Francesco Virlinzi <francesco.virlinzi@st.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

You never free the IRQ in the driver close path, so it leaks.
