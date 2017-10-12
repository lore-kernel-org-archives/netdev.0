From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 3/4] net: qcom/emac: enforce DMA address restrictions
Date: Thu, 12 Oct 2017 09:13:25 -0500
Message-ID: <e523734d-d845-8eae-4a5b-e679b8e46654@codeaurora.org>
References: <1507751546-10265-1-git-send-email-timur@codeaurora.org>
 <1507751546-10265-4-git-send-email-timur@codeaurora.org>
 <063D6719AE5E284EB5DD2968C1650D6DD00923AE@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:44210 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752969AbdJLON3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 10:13:29 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD00923AE@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/17 4:30 AM, David Laight wrote:
> Isn't the memory allocated by a single kzalloc() call?

dma_alloc_coherenent, actually.

> IIRC that guarantees it doesn't cross a power or 2 boundary less than
> the size.

I'm pretty sure that kzalloc does not make that guarantee, and I don't 
think dma_alloc_coherent does either.

> So if you allocate any size between 4k and 8k it won't cross an odd
> 4k boundary (etc).
> 
> So these checks are entirely pointless.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
