From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rndis: remove private wrapper of __constant_cpu_to_le32
Date: Sat, 14 Feb 2009 22:57:07 -0800 (PST)
Message-ID: <20090214.225707.194301286.davem@davemloft.net>
References: <1234389410.5566.5.camel@brick>
	<200902111412.18233.david-b@pacbell.net>
	<1234390573.5566.13.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david-b@pacbell.net, greg@kroah.com, linville@tuxdriver.com,
	netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58846
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751081AbZBOG5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2009 01:57:13 -0500
In-Reply-To: <1234390573.5566.13.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Wed, 11 Feb 2009 14:16:13 -0800

> On Wed, 2009-02-11 at 14:12 -0800, David Brownell wrote:
> > On Wednesday 11 February 2009, Harvey Harrison wrote:
> > > Use cpu_to_le32 directly as it handles constant folding now, replace direct
> > > uses of __constant_cpu_to_{endian} as well.
> > > 
> > > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> > 
> > Acked-by: David Brownell <dbrownell@users.sourceforge.net>
> > 
> > ... though I'm trusting you that constant folding really *does* work
> > now, as it didn't when all this code was first written.  Easily enough
> > seen if it doesn't:  build on big-endian HW will break on all the
> > "case cpu_to_le32(constant):" branches.  ;)
> 
> Yes, and large parts of the kernel are already moved to using the base versions
> already.  I fixed the constant-folding bits during the creation/consolidation
> of linux/swab.h

Applied, thanks everyone.
