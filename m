From: Meelis Roos <mroos@linux.ee>
Subject: b44 compile error on !PCI
Date: Thu, 2 Aug 2007 19:45:47 +0300 (EEST)
Message-ID: <Pine.SOC.4.64.0708021943510.7589@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:47266 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755872AbXHBQpv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 12:45:51 -0400
Received: from math.ut.ee (math.ut.ee [193.40.36.2])
	by smtp2.it.da.ut.ee (Postfix) with ESMTP id A440F4C0377E
	for <netdev@vger.kernel.org>; Thu,  2 Aug 2007 19:45:47 +0300 (EEST)
Received: from localhost (localhost [127.0.0.1])
	by math.ut.ee (Postfix) with ESMTP id 9AE456ADEB
	for <netdev@vger.kernel.org>; Thu,  2 Aug 2007 19:45:47 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tryng to compile todays git on SBus-only Sparc64 (Ultra 1), no PCI. b44 
is selectable but fails to compile:

  CC [M]  drivers/net/b44.o
drivers/net/b44.c: In function 'b44_sync_dma_desc_for_device':
drivers/net/b44.c:134: error: implicit declaration of function 'dma_sync_single_range_for_device'
drivers/net/b44.c: In function 'b44_sync_dma_desc_for_cpu':
drivers/net/b44.c:144: error: implicit declaration of function 'dma_sync_single_range_for_cpu'

-- 
Meelis Roos (mroos@linux.ee)
