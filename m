From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] flow_keys: n_proto type should be __be16
Date: Thu, 05 Feb 2015 00:40:39 -0800 (PST)
Message-ID: <20150205.004039.1300971539750765425.davem@davemloft.net>
References: <1423085514.31870.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, _govind@gmx.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42295 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754922AbbBEIkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 03:40:40 -0500
In-Reply-To: <1423085514.31870.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Feb 2015 13:31:54 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> (struct flow_keys)->n_proto is in network order, use
> proper type for this.
> 
> Fixes following sparse errors :
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: e0f31d849867 ("flow_keys: Record IP layer protocol in skb_flow_dissect()")

Applied, thanks.
