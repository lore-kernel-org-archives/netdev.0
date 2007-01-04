From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] fib6: Fix fn->leaf == NULL race when inserting new nodes in fib6 tree
Date: Thu, 4 Jan 2007 20:21:47 +0100
Message-ID: <20070104192147.GD8693@postel.suug.ch>
References: <20070104093921.GC8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:59029 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750975AbXADTV2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jan 2007 14:21:28 -0500
To: davem@davemloft.net
Content-Disposition: inline
In-Reply-To: <20070104093921.GC8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Thomas Graf <tgraf@suug.ch> 2007-01-04 10:39
> When inserting new nodes into a fib6 tree, the leaf pointer
> is first to NULL and later corrected when the key gets
> assigned. However, the tree is not locked for this period
> of time, therefore nodes with an invalid leaf pointer
> are accessible. Lookups that occur during this period of time
> expect a valid leaf pointer and thus crash.
> 
> This patch sets the leaf pointer to ip6_null_entry during
> this critical period of time.

Ignore this patch for now, the description is certainly inaccurate
even though it seems to fix the issue.
