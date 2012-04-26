From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] allow skb->head to point/alias to first skb frag
Date: Thu, 26 Apr 2012 16:12:21 -0400 (EDT)
Message-ID: <20120426.161221.923108657396544878.davem@davemloft.net>
References: <CANP3RGdnZk5b-gMkF8BPScrp9xos4X1u3n58ocuBQhTT7taE8A@mail.gmail.com>
	<1335443554.2775.33.camel@edumazet-glaptop>
	<1335448252.2775.41.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maze@google.com, ilpo.jarvinen@helsinki.fi, rick.jones2@hp.com,
	netdev@vger.kernel.org, therbert@google.com, ncardwell@google.com,
	ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34960 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757042Ab2DZUMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 16:12:44 -0400
In-Reply-To: <1335448252.2775.41.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 26 Apr 2012 15:50:52 +0200

> Here is the raw patch. (tg3 part is dirty and needs some helpers)
> 
> I am working on the TCP coalesce part, the splice() helpers (to avoid a
> copy), and split in five different patches for further
> discussion/inclusion.

Ok, I like it.

I was confused into thinking that you were going to put this head page
into skb_shared_info()'s page vector.  But you're not.
