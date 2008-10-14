From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH 1/6] [NET-NEXT]qlge: Clean up and fix MSI and legacy irq handling.
Date: Tue, 14 Oct 2008 14:14:58 -0700
Message-ID: <20081014211458.GC27393@susedev.qlogic.org>
References: <20081011171614.GA26384@susedev.qlogic.org> <1223745433-26440-1-git-send-email-ron.mercer@qlogic.com> <20081011205903.GA29496@electric-eye.fr.zoreil.com> <20081014201915.GA27393@susedev.qlogic.org> <20081014204025.GB9617@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-driver@qlogic.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:58736 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256AbYJNVPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 17:15:07 -0400
Content-Disposition: inline
In-Reply-To: <20081014204025.GB9617@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 14, 2008 at 10:40:25PM +0200, Francois Romieu wrote:
> Ron Mercer <ron.mercer@qlogic.com> :
> [...]
> > Your example looks much better than what I had, but it reverses the
> > logic and won't work.  What I'm trying to do is skip the operation if
> > we're running with MSIX-multiple interrupts AND it's not context zero.
> 
> Ok, ok.
> 
> > For all other cases we do the operation.  So fixing your suggestion it would
> > be:
> [snip]
> > This is more compact, it's still optimized, but I think it becomes a
> > little hard to read.
> 
> Remove 'unlikely' ?
> 
> > I'll gladly try it and make the change if you
> 
> Your choice. I'm fine with Roland's code as well.
> 
> -- 
> Ueimor

I'll use Roland's as it does the
most with the fewest lines and is easy to understand.

Thanks to both of you.


