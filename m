From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bridge: fix ordering of NEWLINK and NEWNEIGH events
Date: Mon, 03 Oct 2011 12:18:37 -0400 (EDT)
Message-ID: <20111003.121837.1947718127549678987.davem@davemloft.net>
References: <20111001003725.449204345@vyatta.com>
	<20111001003835.282462632@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42875 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752619Ab1JCQSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 12:18:40 -0400
In-Reply-To: <20111001003835.282462632@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 30 Sep 2011 17:37:26 -0700

> When port is added to a bridge, the old code would send the new neighbor
> netlink message before the subsequent new link message. This bug makes
> it difficult to use the monitoring API in an application.
> 
> This code changes the ordering to add the forwarding entry
> after the port is setup. One of the error checks (for invalid address)
> is moved earlier in the process to avoid having to do unwind.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
