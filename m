From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Fri, 21 Sep 2012 12:27:05 -0400 (EDT)
Message-ID: <20120921.122705.1344923255084267186.davem@davemloft.net>
References: <505B773E.9070501@hp.com>
	<1348172722.2669.10.camel@edumazet-glaptop>
	<1348242511.2669.635.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, subramanian.vijay@gmail.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49694 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757358Ab2IUQ1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 12:27:07 -0400
In-Reply-To: <1348242511.2669.635.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 21 Sep 2012 17:48:31 +0200

> There is probably a reason why lo default MTU is 16436 ?

That's what fit into L1 caches back in 1999
