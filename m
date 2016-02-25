From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: fix null deref crash in compat config
 path
Date: Thu, 25 Feb 2016 17:06:48 -0500 (EST)
Message-ID: <20160225.170648.1681675802804094416.davem@davemloft.net>
References: <1456330817-21347-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794AbcBYWGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 17:06:50 -0500
In-Reply-To: <1456330817-21347-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 24 Feb 2016 17:20:17 +0100

> msg.dst_sk needs to be set up with a valid socket because some callbacks
> later derive the netns from it.
> 
> Fixes: 263ea09084d172d ("Revert "genl: Add genlmsg_new_unicast() for unicast message allocation")
> Reported-by: Jon Maloy <maloy@donjonn.com>
> Bisected-by: Jon Maloy <maloy@donjonn.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> Acked-by Jon Maloy <jon.maloy@ericsson.com>

Applied.
