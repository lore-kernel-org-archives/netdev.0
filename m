From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Remove unneeded type cast in skb_truesize_check()
Date: Wed, 07 Nov 2007 16:15:48 -0800 (PST)
Message-ID: <20071107.161548.162501535.davem@davemloft.net>
References: <472FAE5E.8030701@oracle.com>
	<20071105.163320.82203647.davem@davemloft.net>
	<4731D5A0.2090101@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chuck.lever@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41406
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752336AbXKHAPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 19:15:49 -0500
In-Reply-To: <4731D5A0.2090101@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>
Date: Wed, 07 Nov 2007 10:11:28 -0500

> The (int) type cast in that assertion is nothing more than a comment. 
> The compiler promotes that side of the comparison to match the type on 
> the right side, and the explicit type cast is entirely ignored.  So in 
> fact, my patch removed nothing but a mistaken assumption.  The assertion 
> behaves the same after my patch as it did before.

Then please post a patch that makes the assertion work
instead of removing it, by casting both branches of the
comparison to be signed.
