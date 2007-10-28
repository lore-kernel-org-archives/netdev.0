From: Meelis Roos <mroos@linux.ee>
Subject: b44 & ssb link errors on sparc
Date: Sun, 28 Oct 2007 12:48:46 +0200 (EET)
Message-ID: <Pine.SOC.4.64.0710281239280.19006@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:45260 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750997AbXJ1Kst (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Oct 2007 06:48:49 -0400
Received: from math.ut.ee (math.ut.ee [193.40.36.2])
	by smtp2.it.da.ut.ee (Postfix) with ESMTP id 7D10B73D812
	for <netdev@vger.kernel.org>; Sun, 28 Oct 2007 12:48:46 +0200 (EET)
Received: from localhost (localhost [127.0.0.1])
	by math.ut.ee (Postfix) with ESMTP id 606096ADEB
	for <netdev@vger.kernel.org>; Sun, 28 Oct 2007 12:48:46 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  MODPOST 434 modules
ERROR: "ioremap" [drivers/ssb/ssb.ko] undefined!
ERROR: "iounmap" [drivers/ssb/ssb.ko] undefined!
ERROR: "dma_alloc_coherent" [drivers/net/b44.ko] undefined!
ERROR: "dma_get_cache_alignment" [drivers/net/b44.ko] undefined!
ERROR: "dma_free_coherent" [drivers/net/b44.ko] undefined!
ERROR: "dma_mapping_error" [drivers/net/b44.ko] undefined!
ERROR: "dma_map_single" [drivers/net/b44.ko] undefined!
ERROR: "dma_sync_single_for_cpu" [drivers/net/b44.ko] undefined!
ERROR: "dma_sync_single_range_for_cpu" [drivers/net/b44.ko] undefined!
ERROR: "dma_unmap_single" [drivers/net/b44.ko] undefined!

Do SSB and B44 need to depend on DMA API? They can be selected on 32-bit 
sparc architecture but do not link. This is 2.6.24-rc1 + yesterdays git.

-- 
Meelis Roos (mroos@linux.ee)
