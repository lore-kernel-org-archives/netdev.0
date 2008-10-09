From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/6] bnx2: Handle DMA mapping errors.
Date: Thu, 09 Oct 2008 12:26:49 -0700 (PDT)
Message-ID: <20081009.122649.209282055.davem@davemloft.net>
References: <1223572568-1298-1-git-send-email-mchan@broadcom.com>
	<1223572568-1298-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45824
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760635AbYJIT1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 15:27:13 -0400
In-Reply-To: <1223572568-1298-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu,  9 Oct 2008 10:16:07 -0700

> Before, the driver would not care about the return codes from pci_map_*
> functions.  This could be potentially dangerous if a mapping failed.
> Now, we will check all pci_map_* calls.  On the transmit side, we switch
> to use the new function skb_dma_map().  On the receive side, we add
> pci_dma_mapping_error().
> 
> Signed-off-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
