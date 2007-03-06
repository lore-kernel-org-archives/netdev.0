From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Please revert disallowing zero listen queues
Date: Tue, 06 Mar 2007 10:37:06 -0800 (PST)
Message-ID: <20070306.103706.68156515.davem@davemloft.net>
References: <200703061332.09677@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, weid@np.css.fujitsu.com
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35062
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965991AbXCFShJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 13:37:09 -0500
In-Reply-To: <200703061332.09677@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 6 Mar 2007 13:32:09 +0000

> Please can you reconsider the patch regarding the accept_queue
> 
> http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.22.git;a=commit;h=8488df894d05d6fa41c2bd298c335f944bb0e401
> 
> It disallows to set a `backlog' argument to listen(2) of zero. Using
> a zero backlog is often done (e.g. ttcp), and disallowing a zero 
> backlog will break many applications. I had to recode several applications
> which rely on this convention.
> 
> The problem further spreads from TCP to DCCP (same behaviour).
> 
> Below is a patch to revert this change.

Everything I've ever seen clearly states that a backlog of
zero means that zero connections are allowed.

So we're not "disallowing" a backlog argument of zero to
listen().  We'll accept that just fine, the only thing that
happens is that you'll get what you ask for, that being
no connections :-)
