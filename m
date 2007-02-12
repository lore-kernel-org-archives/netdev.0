From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/3] tcp: remove experimental variants from default list
Date: Mon, 12 Feb 2007 14:53:51 -0800 (PST)
Message-ID: <20070212.145351.35661569.davem@davemloft.net>
References: <20070212191101.GP25760@galon.ev-en.org>
	<20070212.122058.63127043.davem@davemloft.net>
	<20070212221241.GQ25760@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56405
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030447AbXBLWxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 17:53:52 -0500
In-Reply-To: <20070212221241.GQ25760@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baruch Even <baruch@ev-en.org>
Date: Tue, 13 Feb 2007 00:12:41 +0200

> The problem is that you actually put a mostly untested algorithm as the
> default for everyone to use. The BIC example is important, it was the
> default algorithm for a long while and had implementation bugs that no
> one cared for.

And if our TCP Reno implementation had some bugs, what should
we change the default to?  This is just idiotic logic.

These kinds of comments are just wanking, and lead to nowhere,
so please kill the noise.

If we have bugs in a particular algorithm, we should just fix
them.

> As to the reasoning that the new algorithms are supposed to act like
> Reno, that needs to be verified as well, it's not evident from the
> code itself.

If you're not convinced and are intrested enough, then you should go
verify whether it is in fact true.  This is how things work.

If you find that it isn't true, great then we'll know about it and
have an opportunity to fix the bug.
