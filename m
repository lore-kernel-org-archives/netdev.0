From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Disambiguate kernel message
Date: Wed, 01 Feb 2012 14:42:26 -0500 (EST)
Message-ID: <20120201.144226.1972220684681132136.davem@davemloft.net>
References: <1328043341.8702.3.camel@joe2Laptop>
	<20120131.161535.422381201029777577.davem@davemloft.net>
	<20120131220521.GA1505@dev3310.snc6.facebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, bhelgaas@google.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, glommer@parallels.com, mingo@elte.hu,
	christoph.paasch@uclouvain.be
To: asharma@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120131220521.GA1505@dev3310.snc6.facebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arun Sharma <asharma@fb.com>
Date: Tue, 31 Jan 2012 14:05:22 -0800

> From: Arun Sharma <asharma@fb.com>
> Date: Mon, 30 Jan 2012 14:16:06 -0800
> Subject: [PATCH] net: Disambiguate kernel message
> 
> Some of our machines were reporting:
> 
> TCP: too many of orphaned sockets
> 
> even when the number of orphaned sockets was well below the
> limit.
> 
> We print a different message depending on whether we're out
> of TCP memory or there are too many orphaned sockets.
> 
> Also move the check out of line and cleanup the messages
> that were printed.
> 
> Signed-off-by: Arun Sharma <asharma@fb.com>
> Suggested-by: Mohan Srinivasan <mohan@fb.com>

Applied, thanks.
