From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 3/20][BNX2]: Add 40-bit DMA workaround for 5708.
Date: Wed, 2 May 2007 08:23:40 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC09400DB@nt-irva-0751.brcm.ad.broadcom.com>
References: <20070502.001243.70193466.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4743 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993358AbXEBPYp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 11:24:45 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070502.001243.70193466.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> From: Jeff Garzik <jeff@garzik.org>
> Date: Wed, 02 May 2007 03:06:43 -0400
> 
> > Second, CONFIG_HIGHMEM is a bad test for IOMMU presence.  I don't
> > think you /can/ test for IOMMU presence.  Maybe DaveM knows a way
> > that I do not?
> 
> You really can't.
> 
> We have platforms that are both IOMMU and non-IOMMU for the same
> configuration, it isn't known until run-time.
> 
> 
A non-IOMMU system using 64-bit dma_addr_t will always set
CONFIG_HIGHMEM, right?

