From: Kim Phillips <kim.phillips@arm.com>
Subject: Re: [PATCH net] amd-xgbe: Fix DMA API debug warning
Date: Mon, 6 Jul 2015 18:30:21 -0500
Message-ID: <20150706183021.f105b4fd8e9e39cf6b1989b2@arm.com>
References: <20150706165737.2337.95787.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu-smtp-delivery-143.mimecast.com ([146.101.78.143]:37701 "EHLO
	eu-smtp-delivery-143.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751862AbbGFXai convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2015 19:30:38 -0400
In-Reply-To: <20150706165737.2337.95787.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 6 Jul 2015 09:57:37 -0700
Tom Lendacky <thomas.lendacky@amd.com> wrote:

> When running a kernel configured with CONFIG_DMA_API_DEBUG=y a warning
> is issued:
>   DMA-API: device driver tries to sync DMA memory it has not allocated
>
> This warning is the result of mapping the full range of the Rx buffer
> pages allocated and then performing a dma_sync_single_for_cpu against
> a calculated DMA address. The proper thing to do is to use the
> dma_sync_single_range_for_cpu with a base DMA address and an offset.
>
> Reported-by: Kim Phillips <kim.phillips@arm.com>
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---

That works, thanks!

Tested-by: Kim Phillips <kim.phillips@arm.com>

Kim


-- IMPORTANT NOTICE: The contents of this email and any attachments are confidential and may also be privileged. If you are not the intended recipient, please notify the sender immediately and do not disclose the contents to any other person, use it for any purpose, or store or copy the information in any medium.  Thank you.

ARM Limited, Registered office 110 Fulbourn Road, Cambridge CB1 9NJ, Registered in England & Wales, Company No:  2557590
ARM Holdings plc, Registered office 110 Fulbourn Road, Cambridge CB1 9NJ, Registered in England & Wales, Company No:  2548782
