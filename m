From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 4/4] mISDN: misc timerdev fixes
Date: Tue, 23 Sep 2008 04:27:32 +0200
Message-ID: <20080923022731.GE25711@one.firstfloor.org>
References: <200809222151.m8MLp3tb031906@imap1.linux-foundation.org> <20080922.191826.16007223.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, kkeil@suse.de, netdev@vger.kernel.org,
	andi@firstfloor.org, ak@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:41058 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754792AbYIWCWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:22:41 -0400
Content-Disposition: inline
In-Reply-To: <20080922.191826.16007223.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 22, 2008 at 07:18:26PM -0700, David Miller wrote:
> From: akpm@linux-foundation.org
> Date: Mon, 22 Sep 2008 14:51:03 -0700
> 
> > - Remove noop VFS stubs. The VFS does that on a NULL pointer anyways.
> > - Fix timer handler prototype to be correct
> > - Comment ugly SMP race I didn't fix.
> > 
> > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> Applied to net-next-2.6

I'm hoping someone takes care of the SMP race. I think the timers
need all reference counting similar to other network objects to
handle this cleanly.

It might be a good idea to mark it BROKEN_ON_SMP in the meantime.

-Andi

-- 
ak@linux.intel.com
