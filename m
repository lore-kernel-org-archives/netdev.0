From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: RFC:  Removing busy-spin in pktgen.
Date: Tue, 24 Oct 2006 11:16:05 +0200
Message-ID: <17725.55765.509953.762136@robur.slu.se>
References: <453D582C.9020705@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:47567 "EHLO mx1.slu.se")
	by vger.kernel.org with ESMTP id S965117AbWJXJQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 05:16:07 -0400
Received: from robur.slu.se (robur.slu.se [130.238.98.12])
	by mx1.slu.se (8.13.7/8.13.6) with ESMTP id k9O9G5Fl020464
	for <netdev@vger.kernel.org>; Tue, 24 Oct 2006 11:16:06 +0200
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <453D582C.9020705@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ben Greear writes:
 > I'm planning to re-merge my long-lost pktgen branch with the kernel
 > tree's pktgen.
 > 
 > I believe the main difference is that my out-of-tree pktgen does not do the
 > busy-spin, but waits on a queue for the net-device to wake it's tx-queue
 > when over-driving a NIC.
 > 
 > To implement this, I added a hook in the netdev-wake-queue logic and let
 > pktgen register itself as interested....
 > 
 > Is there any interest in adding this sort of feature to the official
 > pktgen?

 Hello!

 So question is, pktgen hooks in netif_wake_queue or let pktgen busy-spin?

 My first instinct is to avoid the hook in general code and pktgen let spin 
 to only affect testing.
 
 Cheers.
					--ro
