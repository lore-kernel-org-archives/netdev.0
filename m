From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 40132] New: kernel BUG at mm/slab.c:501, when in kfree
 from ipv4_frags_exit_net
Date: Thu, 28 Jul 2011 09:13:33 -0700 (PDT)
Message-ID: <20110728.091333.243777794824583455.davem@davemloft.net>
References: <20110728083526.6f55bee9@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755154Ab1G1QOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 12:14:35 -0400
In-Reply-To: <20110728083526.6f55bee9@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 28 Jul 2011 08:35:26 -0700

> 
> 
> Begin forwarded message:

I think the first OOPS in path_init() potentially corrupts his memory,
and then all bets are off.

There's a lot of SUNRPC failures in these traces too.

Close this and tell the reporter to reopen the bug if it persists after
getting rid of the initial crashes that happen first.

