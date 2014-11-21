From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] defxx: Assorted fixes, mainly for EISA
Date: Fri, 21 Nov 2014 16:37:46 -0500 (EST)
Message-ID: <20141121.163746.172766926955262081.davem@davemloft.net>
References: <alpine.LFD.2.11.1411211107150.4773@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39278 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbaKUVhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 16:37:51 -0500
In-Reply-To: <alpine.LFD.2.11.1411211107150.4773@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Fri, 21 Nov 2014 14:09:47 +0000 (GMT)

>  This is another small series fixing issues with the defxx driver, 
> mainly for EISA boards, but there's one patch for PCI as well.
> 
>  In the end, with the inexistent second IDE channel forcefully disabled 
> in the IDE driver, I wasn't able to retrigger spurious IRQ 15 interrupts 
> I previously saw and suspected the DEFEA to be the cause.  So it looks 
> to me these were real noise on IRQ 15 rather than the latency in 
> interrupt acknowledge in the DEFEA board causing the slave 8259A to 
> issue the spurious interrupt vector.  In any case not an issue with the 
> defxx driver, so nothing to do here unless the problem resurfaces.
> 
>  I haven't seen your announcement about opening net-next since the 
> closure on Oct 6th, but from the patch traffic and the policy described 
> in Documentation/networking/netdev-FAQ.txt I gather your tree is open.  
> And these are bug fixes anyway, not new features, so please apply.

Series applied to net-next, thanks.
