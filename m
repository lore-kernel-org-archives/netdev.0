From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Strange soft lockup detected message (looks like spin_lock bug in pcnet32)
Date: Fri, 4 May 2007 11:19:34 -0400
Message-ID: <20070504151934.GA8754@csclub.uwaterloo.ca>
References: <20070503203143.GA8753@csclub.uwaterloo.ca> <20070504141024.GB8753@csclub.uwaterloo.ca> <20070504143326.GD24769@slug>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Frederik Deweerdt <deweerdt@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:53745 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933089AbXEDPTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 11:19:35 -0400
Content-Disposition: inline
In-Reply-To: <20070504143326.GD24769@slug>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 04, 2007 at 04:33:26PM +0200, Frederik Deweerdt wrote:
> On Fri, May 04, 2007 at 10:10:24AM -0400, Lennart Sorensen wrote:
> > On Thu, May 03, 2007 at 04:31:43PM -0400, Lennart Sorensen wrote:
> [...]
> > Should line 2563 be a spin_lock_irqsave instead along with the
> > appropriate unluck later?
> IIRC, when you enable lockdep, it will complain about spinlocks used in
> an invalid context.

What is lockdep and how do I enable it?

I enabled SPINLOCK_DEBUG and am going to try that kernel now (except it
hit the bug before I could even log in and install the kernel this time,
so another reboot first).

--
Len Sorensen
