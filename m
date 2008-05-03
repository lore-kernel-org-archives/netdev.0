From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 0/8][BONDING]: Some BUGs and deadlocks fixes and a bit of concomitant cleanups.
Date: Fri, 02 May 2008 17:25:52 -0700
Message-ID: <32522.1209774352@death>
References: <481735F4.30909@openvz.org> <20080502.170643.71090198.davem@davemloft.net>
Cc: xemul@openvz.org, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:51668 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762179AbYECA0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2008 20:26:00 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m430S5U6012138
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 20:28:05 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m430PvbR235176
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 20:25:57 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m430PuH9023889
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 20:25:57 -0400
In-reply-to: <20080502.170643.71090198.davem@davemloft.net> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>From: Pavel Emelyanov <xemul@openvz.org>
>Date: Tue, 29 Apr 2008 18:51:32 +0400
>
>> While looking at the bonding driver I found four bugs visible with
>> the unaided eye. Here are the fixes, but I also cleaned up some
>> places, I just couldn't come by. If you consider those cleanups to
>> be for next merge window, just kick me and I'll resubmit this set
>> without them.
>
>I think all of these patches are excellent.
>
>Jay, et al., can you make sure these go to Jeff and
>get integrated?

	Yep, I played with them today, and am passing on the bug fixes
for 2.6.26 and the cleanups for -next.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
