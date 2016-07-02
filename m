From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: Fix null-function call in ISR on
 stmmac1000
Date: Sat, 02 Jul 2016 14:36:44 -0400 (EDT)
Message-ID: <20160702.143644.1206479755314521348.davem@davemloft.net>
References: <4B218985-EF8E-47C0-A682-A3E41BE90003@bluematt.me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-amlogic@lists.infradead.org,
	martin.blumenstingl@googlemail.com, peppe.cavallaro@st.com,
	alexandre.torgue@st.com, netdev@vger.kernel.org
To: linux@bluematt.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from [184.105.139.130] ([184.105.139.130]:37708 "EHLO
	shards.monkeyblade.net" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751658AbcGBSrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 14:47:22 -0400
In-Reply-To: <4B218985-EF8E-47C0-A682-A3E41BE90003@bluematt.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Corallo <linux@bluematt.me>
Date: Thu, 30 Jun 2016 19:46:16 +0000

> (resent due to overhelpful mail client corrupting patch)
> 
> At least on Meson GXBB, the CORE_IRQ_MTL_RX_OVERFLOW interrupt is thrown
> with the stmmac1000 driver, which does not support set_rx_tail_ptr. With
> this patch and the clock fixes, 1G ethernet works on ODROID-C2.
> 
> Signed-off-by: Matt Corallo <git@bluematt.me>

Applied.
