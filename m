From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.22 UDP stalls/hangs
Date: Mon, 23 Apr 2007 15:15:31 -0700 (PDT)
Message-ID: <20070423.151531.70219647.davem@davemloft.net>
References: <20070423.141706.92341313.davem@davemloft.net>
	<20070423144557.8c74c4b0.akpm@linux-foundation.org>
	<20070423151240.0e8cabed.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53259
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754349AbXDWWPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 18:15:24 -0400
In-Reply-To: <20070423151240.0e8cabed.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 23 Apr 2007 15:12:40 -0700

> which is just stupid.  The rtnl_lock() is right there in ip_mc_join_group().
> And this is a different architecture and config and compiler from yesterday's
> fun.  And no scheduler patches involved here.

Perhaps something on another cpu is dropping the rtnl semaphore one
times too many.

Recently a bug of this nature was discovered in the wireless stack.
But unless you have a wireless device in this box too, it's probably
unrelated.
