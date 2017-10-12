From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 3/4] net: qcom/emac: enforce DMA address restrictions
Date: Thu, 12 Oct 2017 11:52:58 -0500
Message-ID: <c1ddf6d6-c28f-2bfc-c5e4-dcb065019fb3@codeaurora.org>
References: <1507751546-10265-1-git-send-email-timur@codeaurora.org>
 <1507751546-10265-4-git-send-email-timur@codeaurora.org>
 <063D6719AE5E284EB5DD2968C1650D6DD00923AE@AcuExch.aculab.com>
 <e523734d-d845-8eae-4a5b-e679b8e46654@codeaurora.org>
 <063D6719AE5E284EB5DD2968C1650D6DD0092ADF@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:48682 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751040AbdJLQxA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 12:53:00 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0092ADF@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/2017 11:20 AM, David Laight wrote:
>> I'm pretty sure that kzalloc does not make that guarantee, and I don't
>> think dma_alloc_coherent does either.

> dma_alloc_coherent() definitely does.
> And I've a driver that relies on it (for 16k blocks).

What about when an IOMMU is used?  The DMA address that gets returned is 
not necessarily the physical address of the memory buffer.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
