From: Ben Greear <greearb@candelatech.com>
Subject: RFC:  Removing busy-spin in pktgen.
Date: Mon, 23 Oct 2006 17:02:52 -0700
Message-ID: <453D582C.9020705@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:22760 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932348AbWJXAE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2006 20:04:28 -0400
To: NetDev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm planning to re-merge my long-lost pktgen branch with the kernel
tree's pktgen.

I believe the main difference is that my out-of-tree pktgen does not do the
busy-spin, but waits on a queue for the net-device to wake it's tx-queue
when over-driving a NIC.

To implement this, I added a hook in the netdev-wake-queue logic and let
pktgen register itself as interested....

Is there any interest in adding this sort of feature to the official
pktgen?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

