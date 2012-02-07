From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3] net/sched: sch_plug - Queue traffic until an
 explicit release command
Date: Tue, 07 Feb 2012 12:57:45 -0500 (EST)
Message-ID: <20120207.125745.676129087240196385.davem@davemloft.net>
References: <1328485892-16721-1-git-send-email-rshriram@cs.ubc.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, hagen@jauu.net,
	brendan@cs.ubc.ca
To: rshriram@cs.ubc.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276Ab2BGR5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 12:57:54 -0500
In-Reply-To: <1328485892-16721-1-git-send-email-rshriram@cs.ubc.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: rshriram@cs.ubc.ca
Date: Sun,  5 Feb 2012 15:51:32 -0800

> From: Shriram Rajagopalan <rshriram@cs.ubc.ca>
> 
> The qdisc supports two operations - plug and unplug. When the
> qdisc receives a plug command via netlink request, packets arriving
> henceforth are buffered until a corresponding unplug command is received.
> Depending on the type of unplug command, the queue can be unplugged
> indefinitely or selectively.
> 
> This qdisc can be used to implement output buffering, an essential
> functionality required for consistent recovery in checkpoint based
> fault-tolerance systems. Output buffering enables speculative execution
> by allowing generated network traffic to be rolled back. It is used to
> provide network protection for Xen Guests in the Remus high availability
> project, available as part of Xen.
> 
> This module is generic enough to be used by any other system that wishes
> to add speculative execution and output buffering to its applications.
> 
> This module was originally available in the linux 2.6.32 PV-OPS tree,
> used as dom0 for Xen.
> 
> For more information, please refer to http://nss.cs.ubc.ca/remus/
> and http://wiki.xensource.com/xenwiki/Remus
> 
> Changes in V3:
>   * Removed debug output (printk) on queue overflow
>   * Added TCQ_PLUG_RELEASE_INDEFINITE - that allows the user to
>     use this qdisc, for simple plug/unplug operations.
>   * Use of packet counts instead of pointers to keep track of
>     the buffers in the queue.
> 
> Signed-off-by: Shriram Rajagopalan <rshriram@cs.ubc.ca>
> Signed-off-by: Brendan Cully <brendan@cs.ubc.ca>
> [author of the code in the linux 2.6.32 pvops tree]

Applied, thanks.
