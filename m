From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add tracepoints to socket api
Date: Sun, 01 Feb 2009 02:02:47 -0800 (PST)
Message-ID: <20090201.020247.247498390.davem@davemloft.net>
References: <20090127.102141.99756103.davem@davemloft.net>
	<20090127184704.GA26403@infradead.org>
	<20090128212809.GA19228@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44828
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751395AbZBAKCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 05:02:50 -0500
In-Reply-To: <20090128212809.GA19228@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 28 Jan 2009 16:28:09 -0500

> Of course, these provided tracepoints don't do that, but I think it
> would be good to get the existing tracepoint set in before I go
> poking at an implementation of that, just to ensure I avoid
> duplicate work

Christoph's point is that it doesn't make any sense to merge
this stuff in without any upstream users.

The block stuff has such users, this net syscall trace stuff doesn't.

Now your "where is the packet dropped" trace thing, that would
something we could merge once that patch and a suitable tool exists.
Just like the block layer cases.

So I have to toss this patch for now, sorry.
