From: David Miller <davem@davemloft.net>
Subject: Re: [patch] pktgen: bug when calling ndelay in x86 architectures
Date: Thu, 20 Oct 2011 17:02:27 -0400 (EDT)
Message-ID: <20111020.170227.1948680265756733341.davem@davemloft.net>
References: <1318949264.2657.97.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111020.162444.559487256559727633.davem@davemloft.net>
	<1319144138.2854.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, daniel.turull@gmail.com,
	netdev@vger.kernel.org, robert@herjulf.net, voravit@kth.se,
	jens.laas@uadm.uu.se
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34729 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751978Ab1JTVEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 17:04:42 -0400
In-Reply-To: <1319144138.2854.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Oct 2011 22:55:38 +0200

> Well, I am not sure a patch is needed for net, since there is no bug,
> but maybe small inaccuracies ? Correct me if I misunderstood Daniel !

Ok that appears to be the case, so this is not something we should
deal with in the 'net' tree.

The constant ndelay() case would purposely cause a build failure for
values larger than 40000, but the specific call site we are discussing
in pktgen is never constant and therefore should would never trigger
that bug check.

>> Eric, could you please formally submit this patch with proper
>> changelog etc.?
> 
> Sure !
> 
> [PATCH net-next] pktgen: remove ndelay() call

Applied, thanks!
