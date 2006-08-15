From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch RFC 3/3] b44: convert to ssb module
Date: Tue, 15 Aug 2006 08:12:54 -0400
Message-ID: <20060815121248.GA28544@tuxdriver.com>
References: <200608150014.19661.mb@bu3sch.de> <200608150018.39548.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	zambrano@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:48913 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1752106AbWHOMNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 08:13:41 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200608150018.39548.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 15, 2006 at 12:18:39AM +0200, Michael Buesch wrote:

> @@ -2093,13 +2015,13 @@
>  	bp->imask = IMASK_DEF;
>  
>  	bp->core_unit = ssb_core_unit(bp);
> -	bp->dma_offset = SB_PCI_DMA;
> +	bp->dma_offset = 0x40000000; /* Client Mode PCI memory access space (1GB) */

Probably shouldn't change anything to a magic number...

-- 
John W. Linville
linville@tuxdriver.com
