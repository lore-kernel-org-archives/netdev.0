From: Frederik Deweerdt <deweerdt@free.fr>
Subject: Re: Strange soft lockup detected message (looks like spin_lock bug in pcnet32)
Date: Fri, 4 May 2007 17:34:38 +0200
Message-ID: <20070504153438.GE24769@slug>
References: <20070503203143.GA8753@csclub.uwaterloo.ca> <20070504141024.GB8753@csclub.uwaterloo.ca> <20070504143326.GD24769@slug> <20070504151934.GA8754@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:39552 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030760AbXEDPfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 11:35:38 -0400
Received: by ug-out-1314.google.com with SMTP id 44so669563uga
        for <netdev@vger.kernel.org>; Fri, 04 May 2007 08:35:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070504151934.GA8754@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 04, 2007 at 11:19:34AM -0400, Lennart Sorensen wrote:
> On Fri, May 04, 2007 at 04:33:26PM +0200, Frederik Deweerdt wrote:
> > On Fri, May 04, 2007 at 10:10:24AM -0400, Lennart Sorensen wrote:
> > > On Thu, May 03, 2007 at 04:31:43PM -0400, Lennart Sorensen wrote:
> > [...]
> > > Should line 2563 be a spin_lock_irqsave instead along with the
> > > appropriate unluck later?
> > IIRC, when you enable lockdep, it will complain about spinlocks used in
> > an invalid context.
> 
> What is lockdep and how do I enable it?
For the "what" part, see Documentation/lockdep-design.txt. You'll enable
it by with SPINLOCK_DEBUG, indeed.
> 
> I enabled SPINLOCK_DEBUG and am going to try that kernel now (except it
> hit the bug before I could even log in and install the kernel this time,
> so another reboot first).
> 
> --
> Len Sorensen
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
