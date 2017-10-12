From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] net: qcom/emac: enforce DMA address restrictions
Date: Thu, 12 Oct 2017 09:58:37 -0700 (PDT)
Message-ID: <20171012.095837.2057549694773237248.davem@davemloft.net>
References: <1507751546-10265-4-git-send-email-timur@codeaurora.org>
        <063D6719AE5E284EB5DD2968C1650D6DD00923AE@AcuExch.aculab.com>
        <e523734d-d845-8eae-4a5b-e679b8e46654@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, netdev@vger.kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52892 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752849AbdJLQ6k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 12:58:40 -0400
In-Reply-To: <e523734d-d845-8eae-4a5b-e679b8e46654@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Thu, 12 Oct 2017 09:13:25 -0500

> On 10/12/17 4:30 AM, David Laight wrote:
>> Isn't the memory allocated by a single kzalloc() call?
> 
> dma_alloc_coherenent, actually.
> 
>> IIRC that guarantees it doesn't cross a power or 2 boundary less than
>> the size.
> 
> I'm pretty sure that kzalloc does not make that guarantee, and I don't
> think dma_alloc_coherent does either.

Both make that guarantee, even when an IOMMU is used.
