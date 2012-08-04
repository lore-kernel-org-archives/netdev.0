From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: skb_share_check() should use
 consume_skb()
Date: Sat, 04 Aug 2012 01:28:06 -0700 (PDT)
Message-ID: <20120804.012806.733549497028999835.davem@davemloft.net>
References: <1344063255.9299.1457.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43892 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446Ab2HDI2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 04:28:07 -0400
In-Reply-To: <1344063255.9299.1457.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 04 Aug 2012 08:54:15 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> In order to avoid false drop_monitor indications, we should
> call consume_skb() if skb_clone() was successful.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
