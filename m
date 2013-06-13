From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: Correct byte order of access to skb->{network,
 transport}_header
Date: Thu, 13 Jun 2013 01:22:05 -0700 (PDT)
Message-ID: <20130613.012205.610329066176014278.davem@davemloft.net>
References: <1371107073-26440-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755473Ab3FMIWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 04:22:09 -0400
In-Reply-To: <1371107073-26440-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Thu, 13 Jun 2013 16:04:33 +0900

> Corrects an byte order conflict introduced by
> 158874cac61245b84e939c92c53db7000122b7b0
> ("sctp: Correct access to skb->{network, transport}_header").
> The values in question are host byte order.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>

Applied, thanks Simon.
