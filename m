From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] bridge: Fix undesirable behavior related to
 vlan
Date: Thu, 14 Nov 2013 16:17:21 -0500 (EST)
Message-ID: <20131114.161721.248196700599832767.davem@davemloft.net>
References: <1384331175-4136-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, vyasevic@redhat.com,
	netdev@vger.kernel.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52869 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755273Ab3KNVRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 16:17:24 -0500
In-Reply-To: <1384331175-4136-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Wed, 13 Nov 2013 17:26:11 +0900

> There seem to be some problems around vlan code.
> 
> - Unexpectedly filter vlan by NIC.
> - Not correctly decrement refcount of vlan_vid_info.
> - Memory leak when deleting a bridge with vlan_info allocated.
> 
> This is a patch series to fix these issues.

Series applied, thanks.
