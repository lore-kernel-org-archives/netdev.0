From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] Netfilter updates for net-next
Date: Thu, 13 Sep 2012 14:26:16 -0400 (EDT)
Message-ID: <20120913.142616.429805308274092348.davem@davemloft.net>
References: <1347534092-3579-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48081 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753513Ab2IMS0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 14:26:17 -0400
In-Reply-To: <1347534092-3579-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pablo@netfilter.org
Date: Thu, 13 Sep 2012 13:01:27 +0200

> The following patchset contains four Netfilter updates, mostly targeting
> to fix issues added with IPv6 NAT, and one little IPVS update for net-next:
> 
> * Remove unneeded conditional free of skb in nfnetlink_queue, from
>   Wei Yongjun.
> 
> * One semantic path from coccinelle detected the use of list_del +
>   INIT_LIST_HEAD, instead of list_del_init, again from Wei Yongjun.
> 
> * Fix out-of-bound memory access in the NAT address selection, from
>   Florian Westphal. This was introduced with the IPv6 NAT patches.
> 
> * Two fixes for crashes that were introduced in the recently merged
>   IPv6 NAT support, from myself.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/nf-next master

Also pulled, thanks a lot.
