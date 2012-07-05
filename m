From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] rtcache remove respin
Date: Thu, 05 Jul 2012 03:15:39 -0700 (PDT)
Message-ID: <20120705.031539.2275742387594459652.davem@davemloft.net>
References: <20120701.050243.908285695895815999.davem@davemloft.net>
	<1341225841.5269.69.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55112 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752950Ab2GEKPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 06:15:39 -0400
In-Reply-To: <1341225841.5269.69.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Jul 2012 12:44:01 +0200

> If we still want __refcnt being on cache line boundary, we might find a
> better way to accomplish this.

Back to this issue again.

Eric, if you take a look at net-next right now, I left a dummy padding
in dst_entry where the neighbour pointer used to be.

Can you come up with some way to make use of that new space?
