From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove netdevice gso_min_segs
Date: Thu, 14 Apr 2016 00:37:48 -0400 (EDT)
Message-ID: <20160414.003748.1388631992835456839.davem@davemloft.net>
References: <1460226598.6473.518.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34274 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692AbcDNEhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 00:37:50 -0400
In-Reply-To: <1460226598.6473.518.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 09 Apr 2016 11:29:58 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> After introduction of ndo_features_check(), we believe that very
> specific checks for rare features should not be done in core
> networking stack.
> 
> No driver uses gso_min_segs yet, so we revert this feature and save
> few instructions per tx packet in fast path.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
