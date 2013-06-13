From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: stmicro: stmmac: Fix compile error when
 STMMAC_XMIT_DEBUG used
Date: Thu, 13 Jun 2013 01:31:52 -0700 (PDT)
Message-ID: <20130613.013152.180392586047160961.davem@davemloft.net>
References: <1371053103-13536-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dinh.linux@gmail.com,
	peppe.cavallaro@st.com
To: dinguyen@altera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932659Ab3FMIbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 04:31:53 -0400
In-Reply-To: <1371053103-13536-1-git-send-email-dinguyen@altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <dinguyen@altera.com>
Date: Wed, 12 Jun 2013 11:05:03 -0500

> From: Dinh Nguyen <dinguyen@altera.com>
> 
> drivers/net/ethernet/stmicro/stmmac/stmmac_main.c: In function:
> stmmac_xmit drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1902:74:
> error: expected ) before __func__
> 
> Signed-off-by: Dinh Nguyen <dinguyen@altera.com>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> CC: David S. Miller <davem@davemloft.net>

Applied, but this debugging mechanism is completely unacceptable.

We have a dynamic, run time, way to do stuff like this without
peppering up a driver with gross ifdefs.

This driver must be converted over to use "netif_msg_*()" et al.
to guard message logging of different types of events.
