From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: Fixed panic problem with non-tso
Date: Tue, 17 Jan 2017 15:45:12 -0500 (EST)
Message-ID: <20170117.154512.612465430064515761.davem@davemloft.net>
References: <20170117074820.5106-1-ashiduka@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@nxp.com, netdev@vger.kernel.org
To: ashiduka@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43556 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751162AbdAQUpO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 15:45:14 -0500
In-Reply-To: <20170117074820.5106-1-ashiduka@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuusuke Ashiduka <ashiduka@jp.fujitsu.com>
Date: Tue, 17 Jan 2017 16:48:20 +0900

> If highmem and 2GB or more of memory are valid,
> "this_frag-> page.p" indicates the highmem area,
> so the result of page_address() is NULL and panic occurs.
> 
> This commit fixes this by using the skb_frag_dma_map() helper,
> which takes care of mapping the skb fragment properly. Additionally,
> the type of mapping is now tracked, so it can be unmapped using
> dma_unmap_page or dma_unmap_single when appropriate.

This patch submission is lacking a proper signoff.
