From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sgi-xp: fix a use after free
Date: Sun, 19 Jun 2011 16:34:22 -0700 (PDT)
Message-ID: <20110619.163422.520639226110801913.davem@davemloft.net>
References: <1308523956.3539.105.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: holt@sgi.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60514 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754790Ab1FSXe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 19:34:27 -0400
In-Reply-To: <1308523956.3539.105.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 Jun 2011 00:52:36 +0200

> Its illegal to dereference skb after dev_kfree_skb(skb)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Robin Holt <holt@sgi.com>
> ---
> David, I am not sure Robin is active these days, maybe you can take this
> patch, since its clearly network related ?

Right.

Applied, thanks.
