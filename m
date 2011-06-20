From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen: fix race in skb->len access
Date: Mon, 20 Jun 2011 13:05:56 -0700 (PDT)
Message-ID: <20110620.130556.2143867447969480807.davem@davemloft.net>
References: <1308551175.3539.133.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amit.salecha@qlogic.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40377 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754002Ab1FTUGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 16:06:15 -0400
In-Reply-To: <1308551175.3539.133.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 Jun 2011 08:26:15 +0200

> As soon as skb is given to hardware, TX completion can free skb under
> us.
> Therefore, we should update dev stats before kicking the device.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
