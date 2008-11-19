From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] question about inet_listen_lock(), and [PATCH] net:
 listening_hash get a spinlock per bucket
Date: Wed, 19 Nov 2008 15:41:53 -0800 (PST)
Message-ID: <20081119.154153.233063184.davem@davemloft.net>
References: <492199FF.3030205@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59409
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751021AbYKSXlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 18:41:53 -0500
In-Reply-To: <492199FF.3030205@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 17 Nov 2008 17:21:19 +0100

> I was looking at converting tcp ehash/listening_hash rwlocks to spinlocks, and found
> inet_listen_lock()/unlock() definition :

I've known about this weird "bump a counter and sleep" locking thing we do
for listening sockets, but I haven't been able yet to track down the history
and understand why we do this.

There really was a reason, and your suspicion about /proc/net/tcp might be
correct, and of course doesn't really apply these days.

But I don't know for sure yet, and I'd rather not apply thing until I do.

Give me some more time to do the history search, thanks.
