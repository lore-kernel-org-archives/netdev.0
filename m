From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Sat, 15 Dec 2007 21:37:22 -0800 (PST)
Message-ID: <20071215.213722.216395103.davem@davemloft.net>
References: <20071214151136.ae0f969b.akpm@linux-foundation.org>
	<20071215041827.GC25324@gondor.apana.org.au>
	<20071214214418.0ecd5e67.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60688
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750966AbXLPFhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 00:37:23 -0500
In-Reply-To: <20071214214418.0ecd5e67.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 14 Dec 2007 21:44:18 -0800

> That sounds like a bug in mutex_trylock() to me.

I disagree, I have yet to see a legitimate case where doing a trylock
on a mutex lock didn't turn out to be a bug when performed in an
atomic context.

This is particularly true in the networking, the bonding driver
has provided some excellent examples over the years :-)
