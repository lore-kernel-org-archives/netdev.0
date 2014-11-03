From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add rbnode to struct sk_buff
Date: Mon, 03 Nov 2014 16:12:48 -0500 (EST)
Message-ID: <20141103.161248.1708433612392521582.davem@davemloft.net>
References: <1415031593.14083.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wygivan@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49571 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325AbaKCVMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 16:12:51 -0500
In-Reply-To: <1415031593.14083.25.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 03 Nov 2014 08:19:53 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Yaogong replaces TCP out of order receive queue by an RB tree.
> 
> As netem already does a private skb->{next/prev/tstamp} union
> with a 'struct rb_node', lets do this in a cleaner way.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This looks fine, and I'll apply it, thanks.
