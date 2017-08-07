From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] net: stmmac: Add Adaptrum Anarion GMAC glue
 layer
Date: Sun, 06 Aug 2017 21:31:46 -0700 (PDT)
Message-ID: <20170806.213146.2175597918600105021.davem@davemloft.net>
References: <20170728.190155.457209566729295513.davem@davemloft.net>
        <20170804200852.16049-1-alex.g@adaptrum.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, robh+dt@kernel.org
To: alex.g@adaptrum.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50480 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751430AbdHGEbr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 00:31:47 -0400
In-Reply-To: <20170804200852.16049-1-alex.g@adaptrum.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandru Gagniuc <alex.g@adaptrum.com>
Date: Fri,  4 Aug 2017 13:08:51 -0700

> Before the GMAC on the Anarion chip can be used, the PHY interface
> selection must be configured with the DWMAC block in reset.
> 
> This layer covers a block containing only two registers. Although it
> is possible to model this as a reset controller and use the "resets"
> property of stmmac, it's much more intuitive to include this in the
> glue layer instead.
> 
> At this time only RGMII is supported, because it is the only mode
> which has been validated hardware-wise.
> 
> Signed-off-by: Alexandru Gagniuc <alex.g@adaptrum.com>

Applied.
