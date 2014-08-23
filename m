From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/17] tipc: Merge port and socket layer code
Date: Sat, 23 Aug 2014 11:19:24 -0700 (PDT)
Message-ID: <20140823.111924.253251596808475109.davem@davemloft.net>
References: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35374 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbaHWST0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2014 14:19:26 -0400
In-Reply-To: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Fri, 22 Aug 2014 18:09:03 -0400

> After the removal of the TIPC native interface, there is no reason to
> keep a distinction between a "generic" port layer and a "specific"
> socket layer in the code. Throughout the last months, we have posted
> several series that aimed at facilitating removal of the port layer,
> and in particular the port_lock spinlock, which in reality duplicates
> the role normally kept by lock_sock()/bh_lock_sock().
> 
> In this series, we finalize this work, by making a significant number of
> changes to the link, node, port and socket code, all with the aim of
> reducing dependencies between the layers. In the final commits, we then
> remove the port spinlock, port.c and port.h altogether.
> 
> After this series, we have a socket layer that has only few dependencies
> to the rest of the stack, so that it should be possible to continue
> cleanups of its code without significantly affecting other code.

Series applied, thanks Jon.

> It should be noted that commit ##1 and 2 are already in 'net' 
> (ac32c7f705692b92fe12dcbe88fe87136fdfff6f and 
> 02784f1b05b8f241c8180af88869e717e2758593), but not yet in net-next.
> Since they are prerequisites for the rest of the series to apply, I
> prepend them to the series.

I decided to handle this by merging 'net' into 'net-next' and then
just skipping those first two patches in the series.  Thanks for
letting me know about this dependency.
