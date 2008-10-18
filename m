From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] pkt_sched: Control group classifier
Date: Sat, 18 Oct 2008 07:38:10 +0200
Message-ID: <20081018053810.GC12825@one.firstfloor.org>
References: <20081013155715.GZ20815@postel.suug.ch> <873aixksf0.fsf@basil.nowhere.org> <20081017182312.GE20815@postel.suug.ch> <20081017183221.GA12825@one.firstfloor.org> <20081017200916.GF20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:60453 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbYJRFbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2008 01:31:10 -0400
Content-Disposition: inline
In-Reply-To: <20081017200916.GF20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 17, 2008 at 10:09:16PM +0200, Thomas Graf wrote:
> * Andi Kleen <andi@firstfloor.org> 2008-10-17 20:32
> > > softirq_count() simply counts the levels of bh disable.
> > 
> > softirqs always have bh disabled.  So it's always true inside them.
> > And you should know what _bh locks you hold.
> 
> I actually tried "softirq_count() == SOFTIRQ_OFFSET" to see if the

softirq_count() > 0 should work.


> I found explicitely counting softirq_enter() to be more reliable
> without having much of a performance impact. I'm happy with both
> solutions though.

I doubt you'll need a separate ocunter.

-Andi 

-- 
ak@linux.intel.com
