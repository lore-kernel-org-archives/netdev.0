From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: stmmac: add set_mac to the stmmac_ops
Date: Fri, 24 Mar 2017 12:36:52 -0700 (PDT)
Message-ID: <20170324.123652.1821802503059612387.davem@davemloft.net>
References: <20170323134022.18740-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43488 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967445AbdCXTgx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 15:36:53 -0400
In-Reply-To: <20170323134022.18740-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Thu, 23 Mar 2017 14:40:22 +0100

> Two different set_mac functions exists but stmmac_dwmac4_set_mac() is
> only used for enabling and never for disabling.
> So on dwmac4, the MAC RX/TX is never disabled.
> 
> This patch add a generic function pointer set_mac() to stmmac_ops and
> replace all call to stmmac_set_mac/stmmac_dwmac4_set_mac by a call to
> this pointer.
> 
> Since dwmac4_ops is const, set_mac cannot be modified after, and so dwmac4_ops
> is duplioacted like dwmac4_dma_ops.
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Applied.
