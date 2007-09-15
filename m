From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] [IPV6]: Fix oops during flushing corked datagrams.
Date: Fri, 14 Sep 2007 17:18:19 -0700 (PDT)
Message-ID: <20070914.171819.115920330.davem@davemloft.net>
References: <20070913.093051.04296781.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:60811
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754310AbXIOASV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 20:18:21 -0400
In-Reply-To: <20070913.093051.04296781.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 13 Sep 2007 09:30:51 +0900 (JST)

> When we corking sub-datagrams, we do not clone skb->dst for sub-datagrams
> other than the first one, so we get oops if we have multiple sub-datagrams
> here.
> 
> One possible way to fix this is to clone skb->dst for all sub-datagrams,
> but we do not take this approach because skb->dst is not used in other
> places and it is more natural to increment statistics once per a datagram.
> 
> Also applicable for stable releases.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

This is already fixed (by you) in Linus's tree, and I already
plan to submit this to -stable.
