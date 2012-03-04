From: David Miller <davem@davemloft.net>
Subject: Re: sleeping function called from invalid context (rtnetlink)
Date: Sun, 04 Mar 2012 00:47:19 -0500 (EST)
Message-ID: <20120304.004719.1999250972032337740.davem@davemloft.net>
References: <bug-799099-176318@bugzilla.redhat.com>
	<20120301235928.GA28088@redhat.com>
	<1330837214.2730.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org,
	kernel-team@fedoraproject.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41221 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910Ab2CDFr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 00:47:26 -0500
In-Reply-To: <1330837214.2730.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 03 Mar 2012 21:00:14 -0800

> I took a look at this and couldnt find a reason for this error.
> 
> Thats pretty strange...

That was the conclusion I came to when I looked at other instances of
this.

Some piece of state we're not seeing here is being corrupted, thus
corrupting the locking state.
