From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: dwmac_lib: fix interchanged sleep/timeout
 values in DMA reset function
Date: Fri, 13 Oct 2017 10:20:04 -0700 (PDT)
Message-ID: <20171013.102004.2277222434519825101.davem@davemloft.net>
References: <20171012090047.GA4479@ingrassia.epigenesys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: ingrassia@epigenesys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44966 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751138AbdJMRUF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 13:20:05 -0400
In-Reply-To: <20171012090047.GA4479@ingrassia.epigenesys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emiliano Ingrassia <ingrassia@epigenesys.com>
Date: Thu, 12 Oct 2017 11:00:47 +0200

> The DMA reset timeout, used in read_poll_timeout, is
> ten times shorter than the sleep time.
> This patch fixes these values interchanging them, as it was
> before the read_poll_timeout introduction.
> 
> Fixes: 8a70aeca80c2 ("net: stmmac: Use readl_poll_timeout")
> 
> Signed-off-by: Emiliano Ingrassia <ingrassia@epigenesys.com>

Applied.
