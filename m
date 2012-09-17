From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Mon, 17 Sep 2012 12:12:43 -0400 (EDT)
Message-ID: <20120917.121243.1665284878800146060.davem@davemloft.net>
References: <1347868144.26523.71.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58715 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932325Ab2IQQMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 12:12:47 -0400
In-Reply-To: <1347868144.26523.71.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 17 Sep 2012 09:49:04 +0200

> 2) Use order-3 pages (or order-0 pages if page size is >= 32768)

We could do with an audit to make sure drivers (and the stack in
general) can handle SKB frags of length > PAGE_SIZE.

I have no idea whether such problems might actually exist, but
I can say it's a case that gets not so much testing.
