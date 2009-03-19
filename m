From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: pass the proper dev to DMA ops
Date: Wed, 18 Mar 2009 23:28:35 -0700 (PDT)
Message-ID: <20090318.232835.178183479.davem@davemloft.net>
References: <1237306567-32219-1-git-send-email-galak@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, becky.bruce@freescale.com,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42207
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754857AbZCSG2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 02:28:48 -0400
In-Reply-To: <1237306567-32219-1-git-send-email-galak@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Gala <galak@kernel.crashing.org>
Date: Tue, 17 Mar 2009 11:16:07 -0500

> We need to be passing the of_platform device struct into the DMA ops as
> its the one that has the archdata setup to know which low-level DMA ops we
> should be using (not the net_device one).  This isn't an issue until we
> expect the archdata to be setup correctly.
> 
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
> ---
> 
> Dave,
> 
> This is for net-next.  We are working on having per device dma ops for .30 and
> expect the struct device archdata to be setup properly but in .29 we still
> default to a direct DMA ops on ppc32 so this "bug" will never show up.

Applied to net-next-2.6, thanks.
