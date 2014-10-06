From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: skb_segment() provides list head and tail
Date: Mon, 06 Oct 2014 00:38:13 -0400 (EDT)
Message-ID: <20141006.003813.912754832034876042.davem@davemloft.net>
References: <1412373477.17245.5.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412375467.17245.16.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412395159.17245.33.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, therbert@google.com,
	hannes@stressinduktion.org, fw@strlen.de, dborkman@redhat.com,
	jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57745 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbaJFEiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 00:38:16 -0400
In-Reply-To: <1412395159.17245.33.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 03 Oct 2014 20:59:19 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Its unfortunate we have to walk again skb list to find the tail
> after segmentation, even if data is probably hot in cpu caches.
> 
> skb_segment() can store the tail of the list into segs->prev,
> and validate_xmit_skb_list() can immediately get the tail.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
