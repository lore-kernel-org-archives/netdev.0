From: David Miller <davem@davemloft.net>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Mon, 18 Jan 2016 11:24:55 -0500 (EST)
Message-ID: <20160118.112455.212265265553435873.davem@davemloft.net>
References: <20160115142223.1e92be75@redhat.com>
	<20160115.154721.458450438918273509.davem@davemloft.net>
	<20160118112703.6eac71ca@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com,
	alexei.starovoitov@gmail.com, borkmann@iogearbox.net,
	marek@cloudflare.com, hannes@stressinduktion.org, fw@strlen.de,
	pabeni@redhat.com, john.r.fastabend@intel.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40260 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755675AbcARQZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 11:25:00 -0500
In-Reply-To: <20160118112703.6eac71ca@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 18 Jan 2016 11:27:03 +0100

> Down in the driver layer (RX), I think it is too early to categorize
> Related/Unrelated SKB's, because we want to delay touching packet-data
> as long as possible (waiting for the prefetcher to get data into
> cache).

You don't need to touch the headers in order to have a good idea
as to whether there is a strong possibility packets are related
or not.

We have the hash available.
