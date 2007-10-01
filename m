From: "Chris Friesen" <cfriesen@nortel.com>
Subject: sk98lin, jumbo frames, and memory fragmentation
Date: Mon, 01 Oct 2007 14:35:48 -0600
Message-ID: <47015A24.7000701@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: linux@syskonnect.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04f.nortel.com ([47.129.242.57]:56783 "EHLO
	zcars04f.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752549AbXJAUgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 16:36:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi all,

We're considering some hardware that uses the sk98lin network hardware, 
and we'll be using jumbo frames.  Looking at the driver, when using a 
9KB MTU it seems like it would end up trying to atomically allocate a 
16KB buffer.

Has anyone heard of this been a problem?  It would seem like trying to 
atomically allocate four physically contiguous pages could become tricky 
after the system has been running for a while.

The reason I ask is that we ran into this with the e1000.  Before they 
added the new jumbo frame code it was trying to atomically allocate 32KB 
buffers and we would start getting allocation failures after a month or 
so of uptime.

Any information anyone can provide would be appreciated.


Thanks,

Chris
