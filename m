From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: gre: move GSO functions to gre_offload
Date: Wed, 03 Jul 2013 15:00:36 -0700 (PDT)
Message-ID: <20130703.150036.1207414018059569364.davem@davemloft.net>
References: <1372699440-2289-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38554 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773Ab3GCWAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 18:00:39 -0400
In-Reply-To: <1372699440-2289-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon,  1 Jul 2013 19:24:00 +0200

> Similarly to TCP/UDP offloading, move all related GRE functions to
> gre_offload.c to make things more explicit and similar to the rest
> of the code.
> 
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  When net is merged into net-next, this will clash with bd8a7036c06cf1577 ("gre:
>  fix a possible skb leak") in gre_gso_segment() as kfree_skb() is being replaced
>  with kfree_skb_list() in one occurence. How would you like to handle this Dave?
>  This patch is not really urgent though, but maybe we could get this still in
>  before net-next closes.

I've applied this and did the messy merge.

Actually the GRE part wasn't that bad. :-)

Thanks!
