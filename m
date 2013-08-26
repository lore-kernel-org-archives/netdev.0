From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 0/6] SYNPROXY target v2
Date: Mon, 26 Aug 2013 16:24:49 -0400 (EDT)
Message-ID: <20130826.162449.1876700852280042769.davem@davemloft.net>
References: <1377244329-20146-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, mph@one.com, jesper.brouer@gmail.com,
	as@one.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653Ab3HZUYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 16:24:52 -0400
In-Reply-To: <1377244329-20146-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 23 Aug 2013 09:52:03 +0200

> The following patches contain the current version of the SYNPROXY target.
> Changes this the last posting are:
> 
> - use sysctl_ip_default_ttl instead of hardcoding 64
> 
> - use MAX_TCP_HEADER instead of LL_MAX_HEADER
> 
> - add some comments requested by Jesper regarding ack_seq initialization
>   in the server's SYN packet
> 
> - use consume_skb() instead of kfree_skb() in the synproxy hook
> 
> - remove a fixme and add explicit check for "-p tcp" in the SYNPROXY rule
>   in the IPv6 version
> 
> - some whitespace fixes
> 
> - a larger number of fixes for properly handling retransmissions and
>   out of order packets, please see the changelog included in patch 6/6
>   for details.
>   
>   I've kept those in a seperate patch for now to ease review, we'll do
>   some more extensive testing on monday and I'll fold the changes in
>   their respective patches before the final submission.
> 
> Comments welcome.

No objections to the non-netfilter portions:

Acked-by: David S. Miller <davem@davemloft.net>
