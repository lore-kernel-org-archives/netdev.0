From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Update IngPad and IngPack values
Date: Wed, 22 Mar 2017 10:54:00 -0700 (PDT)
Message-ID: <20170322.105400.288226215482946580.davem@davemloft.net>
References: <1489999958-4682-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com, arjun@chelsio.com,
        leedom@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42202 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965202AbdCVRyG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 13:54:06 -0400
In-Reply-To: <1489999958-4682-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Mon, 20 Mar 2017 14:22:38 +0530

> From: Arjun Vynipadath <arjun@chelsio.com>
> 
> We are using the smallest padding boundary (8 bytes), which isn't
> smaller than the Memory Controller Read/Write Size
> 
> We get best performance in 100G when the Packing Boundary is a multiple
> of the Maximum Payload Size. Its related to inefficient chopping of DMA
> packets by PCIe, that causes more overhead on bus. So driver is helping
> by making the starting address alignment to be MPS size.
> 
> We will try to determine PCIE MaxPayloadSize capabiltiy  and set
> IngPackBoundary based on this value. If cache line size is greater than
> MPS or determinig MPS fails, we will use cache line size to determine
> IngPackBoundary(as before).
> 
> Signed-off-by: Arjun Vynipadath <arjun@chelsio.com>
> Signed-off-by: Casey Leedom <leedom@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied, thank you.
