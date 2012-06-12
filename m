From: David Miller <davem@davemloft.net>
Subject: Re: Possible deadlock in ipv6?
Date: Mon, 11 Jun 2012 23:54:53 -0700 (PDT)
Message-ID: <20120611.235453.953830769326224643.davem@davemloft.net>
References: <4FCF6DF4.2090304@parallels.com>
	<1338998019.26966.10.camel@edumazet-glaptop>
	<1338998314.26966.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vdavydov@parallels.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48711 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323Ab2FLGy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 02:54:56 -0400
In-Reply-To: <1338998314.26966.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Jun 2012 17:58:34 +0200

> And it seems this neigh_down() can be removed, its called later
> (after dev->ip6_ptr is cleared)

It is unclear whether we need to do the the neigh_down() in both
the 'how' and '!how' cases.  If so then we can't make this change.
