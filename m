From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: Fix null-function call in ISR on
 stmmac1000
Date: Wed, 29 Jun 2016 03:58:52 -0400 (EDT)
Message-ID: <20160629.035852.1504883332705515951.davem@davemloft.net>
References: <E5152E61-5896-46FD-BF4A-16CDFB3796F6@bluematt.me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-amlogic@lists.infradead.org, peppe.cavallaro@st.com,
	alexandre.torgue@st.com, netdev@vger.kernel.org,
	martin.blumenstingl@googlemail.com
To: linux@bluematt.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38806 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbcF2H7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 03:59:21 -0400
In-Reply-To: <E5152E61-5896-46FD-BF4A-16CDFB3796F6@bluematt.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Corallo <linux@bluematt.me>
Date: Sat, 25 Jun 2016 19:35:03 +0000

> At least on Meson GXBB, the CORE_IRQ_MTL_RX_OVERFLOW interrupt is thrown
> with the stmmac1000 driver, which does not support set_rx_tail_ptr. With
> this patch and the clock fixes, 1G ethernet works on ODROID-C2.
> 
> Signed-off-by: Matt Corallo <git@bluematt.me>

This patch does not apply without rejects to any of my trees.
