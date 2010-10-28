From: Nelson Elhage <nelhage@ksplice.com>
Subject: Re: [patch v3] fix stack overflow in pktgen_if_write()
Date: Thu, 28 Oct 2010 12:30:32 -0400
Message-ID: <20101028163032.GY16803@ksplice.com>
References: <1288206788-21063-1-git-send-email-nelhage@ksplice.com>
 <20101027221234.GN6062@bicker>
 <20101027224302.GQ6062@bicker>
 <20101027230657.GT16803@ksplice.com>
 <20101028060529.GX6062@bicker>
 <20101028152222.GU16803@ksplice.com>
 <20101028162825.GG6062@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	netdev@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:45727 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757001Ab0J1Qaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 12:30:35 -0400
Received: by qwf7 with SMTP id 7so1313473qwf.19
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 09:30:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20101028162825.GG6062@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 28, 2010 at 06:28:25PM +0200, Dan Carpenter wrote:
> On Thu, Oct 28, 2010 at 11:22:22AM -0400, Nelson Elhage wrote:
> > You've got a leak if copy_user fails.
> > 
> 
> My QC scripts should have caught that, but they didn't...  I'll figure
> it out.  It shouldn't happen again.
> 
> > While testing this, I realized that printk() won't print more than 1k in a
> > single call, anyways, so I've sent along a patch that just copies up to 1k onto
> > the stack, which should prevent the overflow without changing behavior or
> > needing a heap allocation.
> > 
> 
> Ok.  Good to hear.  Sorry I wasted people's time.

No worries. I appreciate you jumping in to help, even if it looks like the
approach wasn't needed in the end.

- Nelson

> 
> regards,
> dan carpenter
> 
> 
