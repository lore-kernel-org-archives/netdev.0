From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: igmp: fix v3 general query drop monitor
 false positive
Date: Mon, 06 Oct 2014 17:15:24 -0400 (EDT)
Message-ID: <20141006.171524.1254375922559313117.davem@davemloft.net>
References: <1412522870-26335-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38288 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289AbaJFVP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 17:15:26 -0400
In-Reply-To: <1412522870-26335-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sun,  5 Oct 2014 17:27:50 +0200

> In case we find a general query with non-zero number of sources, we
> are dropping the skb as it's malformed.
> 
> RFC3376, section 4.1.8. Number of Sources (N):
> 
>   This number is zero in a General Query or a Group-Specific Query,
>   and non-zero in a Group-and-Source-Specific Query.
> 
> Therefore, reflect that by using kfree_skb() instead of consume_skb().
> 
> Fixes: d679c5324d9a ("igmp: avoid drop_monitor false positives")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks Daniel.
