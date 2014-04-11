From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: core: don't account for udp header size when
 computing seglen
Date: Thu, 10 Apr 2014 21:42:54 -0400 (EDT)
Message-ID: <20140410.214254.1339000250746969664.davem@davemloft.net>
References: <1397032130-2271-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45679 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754172AbaDKBm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 21:42:56 -0400
In-Reply-To: <1397032130-2271-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed,  9 Apr 2014 10:28:50 +0200

> In case of tcp, gso_size contains the tcpmss.
> 
> For UFO (udp fragmentation offloading) skbs, gso_size is the fragment
> payload size, i.e. we must not account for udp header size.
> 
> Otherwise, when using virtio drivers, a to-be-forwarded UFO GSO packet
> will be needlessly fragmented in the forward path, because we think its
> individual segments are too large for the outgoing link.
> 
> Fixes: fe6cc55f3a9a053 ("net: ip, ipv6: handle gso skbs in forwarding path")
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Reported-by: Tobias Brunner <tobias@strongswan.org>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  changes since v1:
>   - update 'Fixes:' tag.

Applied and queued up for -stable, thanks!
