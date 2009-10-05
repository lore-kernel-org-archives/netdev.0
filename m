From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCPCT+1: initial SYN exchange with SYNACK data
Date: Mon, 05 Oct 2009 01:50:06 -0700 (PDT)
Message-ID: <20091005.015006.125372560.davem@davemloft.net>
References: <4AC9A714.7060903@gmail.com>
	<20091005.010630.214808506.davem@davemloft.net>
	<4AC9AD14.2060500@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57172
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758044AbZJEIuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 04:50:11 -0400
In-Reply-To: <4AC9AD14.2060500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Mon, 05 Oct 2009 04:23:48 -0400

> This will be widely deployed.  Deployment in DNS root servers is
> expected by December.  It will be hammered with 600,000+ queries per
> minute.  Does that impact your design expectations?

Great, so 600,000 times per second we'll take two new atomic
operations with your most recent suggestion...

> Tomorrow, I'll send out a new patch with everything buried in a single
> kref, the various tests will only be a trifle slower....

This one..

The reason we want tcp_sock smaller is to get better performance (less
memory references) and to save memory.  If you're exchanging the space
savings for atomic operations and whatnot, you're defeating half of
the point of making the tcp_sock state smaller.

Make your state take up less space in tcp_sock without making it cost
more in some other form.

And btw, it's not our problem that all of a sudden this is critical
and important for you, and that you don't like how not all aspects of
your implementation were commented upon long ago when the first
implementation was posted.

Your insistence to keep harping on those issues will only irritate me
(and probably others).  So please keep that out of the discussion,
thanks.
