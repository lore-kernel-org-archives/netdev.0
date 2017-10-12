From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 3/4] net: qcom/emac: enforce DMA address restrictions
Date: Thu, 12 Oct 2017 12:15:12 -0500
Message-ID: <4f0055bb-894f-8fe1-b2d3-b6541dbb07a7@codeaurora.org>
References: <1507751546-10265-4-git-send-email-timur@codeaurora.org>
 <063D6719AE5E284EB5DD2968C1650D6DD00923AE@AcuExch.aculab.com>
 <e523734d-d845-8eae-4a5b-e679b8e46654@codeaurora.org>
 <20171012.095837.2057549694773237248.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:38728 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751040AbdJLRPY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:15:24 -0400
In-Reply-To: <20171012.095837.2057549694773237248.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/2017 11:58 AM, David Miller wrote:
>> I'm pretty sure that kzalloc does not make that guarantee, and I don't
>> think dma_alloc_coherent does either.
> Both make that guarantee, even when an IOMMU is used.
> 

Ok, Dave, then can you drop this patch?

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
