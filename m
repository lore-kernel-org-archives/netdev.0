From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "net: qcom/emac: enforce DMA address
 restrictions"
Date: Thu, 12 Oct 2017 10:50:27 -0700 (PDT)
Message-ID: <20171012.105027.2184813224895603918.davem@davemloft.net>
References: <1507830124-19294-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David.Laight@ACULAB.COM
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53946 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750729AbdJLRu2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:50:28 -0400
In-Reply-To: <1507830124-19294-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Thu, 12 Oct 2017 12:42:04 -0500

> This reverts commit df1ec1b9d0df57e96011f175418dc95b1af46821.
> 
> It turns out that memory allocated via dma_alloc_coherent is always
> aligned to the size of the buffer, so there's no way the RRD and RFD
> can ever be in separate 32-bit regions.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

Applied, thanks.
