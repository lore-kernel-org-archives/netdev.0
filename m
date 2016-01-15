From: David Miller <davem@davemloft.net>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Fri, 15 Jan 2016 15:47:21 -0500 (EST)
Message-ID: <20160115.154721.458450438918273509.davem@davemloft.net>
References: <20160115142223.1e92be75@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com,
	alexei.starovoitov@gmail.com, borkmann@iogearbox.net,
	marek@cloudflare.com, hannes@stressinduktion.org, fw@strlen.de,
	pabeni@redhat.com, john.r.fastabend@intel.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33215 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141AbcAOUrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 15:47:24 -0500
In-Reply-To: <20160115142223.1e92be75@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 15 Jan 2016 14:22:23 +0100

> This was only at the driver level.  I also would like some API towards
> the stack.  Maybe we could simple pass a skb-list?

Datastructures are everything so maybe we can create some kind of SKB
bundle abstractions.  Whether it's a lockless array or a linked list
behind it doesn't really matter.

We could have two categories: Related and Unrelated.

If you think about GRO and routing keys you might see what I am getting
at. :-)
