From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] net: add skb_dst_force() in
 sock_queue_err_skb()
Date: Wed, 18 May 2011 02:21:51 -0400 (EDT)
Message-ID: <20110518.022151.1670373958008022789.davem@davemloft.net>
References: <1305673846.6741.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, baryluk@smp.if.uj.edu.pl,
	shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753982Ab1ERGWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 02:22:02 -0400
In-Reply-To: <1305673846.6741.35.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 May 2011 01:10:46 +0200

> Commit 7fee226ad239 (add a noref bit on skb dst) forgot to use
> skb_dst_force() on packets queued in sk_error_queue
> 
> This triggers following warning, for applications using IP_CMSG_PKTINFO
> receiving one error status
 ...
> Close bug https://bugzilla.kernel.org/show_bug.cgi?id=34622
> 
> Reported-by: Witold Baryluk <baryluk@smp.if.uj.edu.pl>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
