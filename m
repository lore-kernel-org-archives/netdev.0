From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/4] net: qcom/emac: enforce DMA address restrictions
Date: Thu, 12 Oct 2017 16:20:16 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0092ADF@AcuExch.aculab.com>
References: <1507751546-10265-1-git-send-email-timur@codeaurora.org>
 <1507751546-10265-4-git-send-email-timur@codeaurora.org>
 <063D6719AE5E284EB5DD2968C1650D6DD00923AE@AcuExch.aculab.com>
 <e523734d-d845-8eae-4a5b-e679b8e46654@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Timur Tabi' <timur@codeaurora.org>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.186]:64170 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751040AbdJLQUU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 12:20:20 -0400
In-Reply-To: <e523734d-d845-8eae-4a5b-e679b8e46654@codeaurora.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi
> Sent: 12 October 2017 15:13
> On 10/12/17 4:30 AM, David Laight wrote:
> > Isn't the memory allocated by a single kzalloc() call?
> 
> dma_alloc_coherenent, actually.
> 
> > IIRC that guarantees it doesn't cross a power or 2 boundary less than
> > the size.
> 
> I'm pretty sure that kzalloc does not make that guarantee, and I don't
> think dma_alloc_coherent does either.

dma_alloc_coherent() definitely does.
And I've a driver that relies on it (for 16k blocks).

	David
