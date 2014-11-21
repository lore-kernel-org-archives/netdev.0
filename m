From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 0/4] defxx: Assorted fixes, mainly for EISA
Date: Fri, 21 Nov 2014 14:09:47 +0000 (GMT)
Message-ID: <alpine.LFD.2.11.1411211107150.4773@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:59728 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755540AbaKUOJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 09:09:48 -0500
Received: from localhost.localdomain ([127.0.0.1]:49954 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S27006519AbaKUOJrGATfs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 15:09:47 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

 This is another small series fixing issues with the defxx driver, 
mainly for EISA boards, but there's one patch for PCI as well.

 In the end, with the inexistent second IDE channel forcefully disabled 
in the IDE driver, I wasn't able to retrigger spurious IRQ 15 interrupts 
I previously saw and suspected the DEFEA to be the cause.  So it looks 
to me these were real noise on IRQ 15 rather than the latency in 
interrupt acknowledge in the DEFEA board causing the slave 8259A to 
issue the spurious interrupt vector.  In any case not an issue with the 
defxx driver, so nothing to do here unless the problem resurfaces.

 I haven't seen your announcement about opening net-next since the 
closure on Oct 6th, but from the patch traffic and the policy described 
in Documentation/networking/netdev-FAQ.txt I gather your tree is open.  
And these are bug fixes anyway, not new features, so please apply.

  Maciej
