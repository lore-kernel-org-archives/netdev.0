From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: generalize MAX_TCP_HEADER usage
Date: Sat, 29 Mar 2014 17:56:54 -0400 (EDT)
Message-ID: <20140329.175654.1000726174039601620.davem@davemloft.net>
References: <1395951546.12610.317.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50844 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbaC2V44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 17:56:56 -0400
In-Reply-To: <1395951546.12610.317.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 27 Mar 2014 13:19:06 -0700

> (Note that sk_stream_alloc_skb() uses MAX_TCP_HEADER anyway...)

But only after your changes.

Please make this clear in the commit message, I had to go check to see
if there were in fact MAX_TCP_HEADER uses in sk_stream_alloc_skb in
the current tree.
