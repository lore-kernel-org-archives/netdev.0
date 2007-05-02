From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 3/20][BNX2]: Add 40-bit DMA workaround for 5708.
Date: Wed, 02 May 2007 11:23:52 -0700
Message-ID: <1178130232.4820.62.camel@dell>
References: <1551EAE59135BE47B544934E30FC4FC09400DB@nt-irva-0751.brcm.ad.broadcom.com>
 <4638AE42.5000908@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev" <netdev@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1643 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1766926AbXEBRny (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 13:43:54 -0400
In-Reply-To: <4638AE42.5000908@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-05-02 at 11:29 -0400, Jeff Garzik wrote:
> Michael Chan wrote:
> > A non-IOMMU system using 64-bit dma_addr_t will always set
> > CONFIG_HIGHMEM, right?
> 
> No.
> 
May be I misunderstood the code in illegal_highdma() in net/core/dev.c
where it is checking to see if it needs to linearize the SKB when the
device does not support 64-bit DMA.  I'm using similar assumptions for
the 40-bit address check in the patch.

