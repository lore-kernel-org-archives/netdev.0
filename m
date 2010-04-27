From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: multicast router list manipulation
Date: Tue, 27 Apr 2010 16:51:51 -0700 (PDT)
Message-ID: <20100427.165151.171482432.davem@davemloft.net>
References: <20100427162530.04deb551@nehalam>
	<20100427.162811.233419535.davem@davemloft.net>
	<20100427164412.791e4999@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirqus@gmail.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32872
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754594Ab0D0Xvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 19:51:45 -0400
In-Reply-To: <20100427164412.791e4999@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 27 Apr 2010 16:44:12 -0700

> Code that doesn't need rcu for traversal should not use it.
> It just confuses things and implies that rcu_read_lock is held
> which it is not in this code.

Fair enough, I've reverted by change.

This would have been helped if either the patch was split up into
two pieces (one straight hlist macro conversion, another removing
the RCU tag) _or_ the commit message explained why the RCU tag
could be elided.
