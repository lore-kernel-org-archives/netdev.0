From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib6: Fix fn->leaf == NULL race when inserting new
 nodes in fib6 tree
Date: Thu, 04 Jan 2007 12:24:49 -0800 (PST)
Message-ID: <20070104.122449.119276319.davem@davemloft.net>
References: <20070104093921.GC8693@postel.suug.ch>
	<20070104192147.GD8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58987
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965081AbXADUYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 15:24:50 -0500
To: tgraf@suug.ch
In-Reply-To: <20070104192147.GD8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 4 Jan 2007 20:21:47 +0100

> * Thomas Graf <tgraf@suug.ch> 2007-01-04 10:39
> > When inserting new nodes into a fib6 tree, the leaf pointer
> > is first to NULL and later corrected when the key gets
> > assigned. However, the tree is not locked for this period
> > of time, therefore nodes with an invalid leaf pointer
> > are accessible. Lookups that occur during this period of time
> > expect a valid leaf pointer and thus crash.
> > 
> > This patch sets the leaf pointer to ip6_null_entry during
> > this critical period of time.
> 
> Ignore this patch for now, the description is certainly inaccurate
> even though it seems to fix the issue.

Ok, no problem.
