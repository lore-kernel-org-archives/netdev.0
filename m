From: Chris Friesen <chris.friesen@genband.com>
Subject: where are the memory barriers in net driver rx DMA operations?
Date: Fri, 30 Jul 2010 09:19:40 -0600
Message-ID: <4C52ED8C.9070709@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7ob116.obsmtp.com ([64.18.2.218]:60030 "EHLO
	exprod7ob116.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759736Ab0G3Sqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jul 2010 14:46:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Documentation/DMA-API-HOWTO.txt says that memory barriers are still
required when accessing consistent mappings.  The example they give is
for reordering stores to consistent memory but I assume this also
applies to reordering loads.

However, I see many net drivers accessing the descriptor ring (in
consistent memory), checking the status bit for the buffer, then calling
dma_unmap_single() and accessing the data without any explicit memory
barrier.  Does the unmapping call act as a barrier in this case?

Thanks,

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
