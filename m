From: Meelis Roos <mroos@linux.ee>
Subject: Re: b44 compile error on !PCI
Date: Sun, 5 Aug 2007 13:03:04 +0300 (EEST)
Message-ID: <Pine.SOC.4.64.0708051302310.12916@math.ut.ee>
References: <Pine.SOC.4.64.0708021943510.7589@math.ut.ee> <200708021917.45876.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:46815 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755115AbXHEKDF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Aug 2007 06:03:05 -0400
In-Reply-To: <200708021917.45876.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >   CC [M]  drivers/net/b44.o
> > drivers/net/b44.c: In function 'b44_sync_dma_desc_for_device':
> > drivers/net/b44.c:134: error: implicit declaration of function 'dma_sync_single_range_for_device'
> > drivers/net/b44.c: In function 'b44_sync_dma_desc_for_cpu':
> > drivers/net/b44.c:144: error: implicit declaration of function 'dma_sync_single_range_for_cpu'
> 
> Are you sure this is related to !PCI ?
> If I grep include/asm-sparc64/dma-mapping.h I don't
> find dma_sync_single_range_for_*
> So I'd rather call this a bug in the arch code of sparc64.

Yes, now that Dave Miller added these functions to sparc64, b44 compiles 
fine.

-- 
Meelis Roos (mroos@linux.ee)
