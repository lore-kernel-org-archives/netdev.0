From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 1/2] tipc: fix link attribute propagation
 bug
Date: Sat, 06 Feb 2016 02:45:56 -0500 (EST)
Message-ID: <20160206.024556.68001450948085226.davem@davemloft.net>
References: <1454311197-10948-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47598 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831AbcBFHqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 02:46:00 -0500
In-Reply-To: <1454311197-10948-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>
Date: Mon, 1 Feb 2016 08:19:56 +0100

> Changing certain link attributes (link tolerance and link priority)
> from the TIPC management tool is supposed to automatically take
> effect at both endpoints of the affected link.
> 
> Currently the media address is not instantiated for the link and is
> used uninstantiated when crafting protocol messages designated for the
> peer endpoint. This means that changing a link property currently
> results in the property being changed on the local machine but the
> protocol message designated for the peer gets lost. Resulting in
> property discrepancy between the endpoints.
> 
> In this patch we resolve this by using the media address from the
> link entry and using the bearer transmit function to send it. Hence,
> we can now eliminate the redundant function tipc_link_prot_xmit() and
> the redundant field tipc_link::media_addr.
> 
> Fixes: 2af5ae372a4b (tipc: clean up unused code and structures)
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
> Reported-by: Jason Hu <huzhijiang@gmail.com>
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>

Applied.
