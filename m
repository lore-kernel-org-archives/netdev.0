From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] bridge: Fix handling stacked vlan tags
Date: Fri, 28 Mar 2014 16:33:42 -0400 (EDT)
Message-ID: <20140328.163342.1681357800958748572.davem@davemloft.net>
References: <1395924416-12325-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<1395924416-12325-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, vyasevic@redhat.com,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40627 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714AbaC1Udo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 16:33:44 -0400
In-Reply-To: <1395924416-12325-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Thu, 27 Mar 2014 21:46:56 +0900

> If a bridge with vlan_filtering enabled receives frames with stacked
> vlan tags, i.e., they have two vlan tags, br_vlan_untag() strips not
> only the outer tag but also the inner tag.
> 
> br_vlan_untag() is called only from br_handle_vlan(), and in this case,
> it is enough to set skb->vlan_tci to 0 here, because vlan_tci has already
> been set before calling br_handle_vlan().
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Applied.
