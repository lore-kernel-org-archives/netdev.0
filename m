From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix sk_buff head without data area
Date: Tue, 04 Jun 2013 17:27:45 -0700 (PDT)
Message-ID: <20130604.172745.973899787878302690.davem@davemloft.net>
References: <1370287723-30168-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520Ab3FEA1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 20:27:46 -0400
In-Reply-To: <1370287723-30168-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon,  3 Jun 2013 21:28:43 +0200

> Eric Dumazet spotted that we have to check skb->head instead
> of skb->data as skb->head points to the beginning of the
> data area of the skbuff. Similarly, we have to initialize the
> skb->head pointer, not skb->data in __alloc_skb_head.
> 
> After this fix, netlink crashes in the release path of the
> sk_buff, so let's fix that as well.
> 
> This bug was introduced in (0ebd0ac net: add function to
> allocate sk_buff head without data area).
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied and queued up for -stable, thanks.
