From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: cleanup and document skb fclone layout
Date: Wed, 01 Oct 2014 16:34:41 -0400 (EDT)
Message-ID: <20141001.163441.940109913971096655.davem@davemloft.net>
References: <1411860341.15768.55.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412022555.30721.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956AbaJAUen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 16:34:43 -0400
In-Reply-To: <1412022555.30721.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 29 Sep 2014 13:29:15 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Lets use a proper structure to clearly document and implement
> skb fast clones.
> 
> Then, we might experiment more easily alternative layouts.
> 
> This patch adds a new skb_fclone_busy() helper, used by tcp and xfrm,
> to stop leaking of implementation details.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> v2: rebased on latest net-next

Applied, thank you.
