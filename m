From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- experimental revert for 2.6.27 failed
Date: Tue, 12 Aug 2008 17:31:07 -0700
Message-ID: <86802c440808121731y5481cf44m54990b88395483c4@mail.gmail.com>
References: <940473.79639.qm@web82108.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"Peter Zijlstra" <peterz@infradead.org>,
	"Ingo Molnar" <mingo@elte.hu>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: "David Witbrodt" <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.225]:46594 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755998AbYHMAbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 20:31:09 -0400
Received: by wr-out-0506.google.com with SMTP id 69so2175185wri.5
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 17:31:07 -0700 (PDT)
In-Reply-To: <940473.79639.qm@web82108.mail.mud.yahoo.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2008 at 5:00 PM, David Witbrodt <dawitbro@sbcglobal.net> wrote:
> SUMMARY
>
> 1.  Ran 'git remote update', then built kernels for origin/master
> (Linus' linux-2.6 tree) and tip/master.  Both froze.
>
> 2.  Attempted a revert against tip/master, but the files involved
> changed quite a bit.  I _was_ able to build the kernel successfully,
> but it froze.  There have simply been too many changes since Feb. 22
> for my naive approach to work.
>
> 3.  When the revert failed, I panicked:  I thought that I might
> truly have made a mistake with the original 'git bisect' process
> I carried out.  After retracing the last few iterations of the
> process -- building and checking the last 3 kernels -- I found
> that the information I posted here WAS correct:  the problem
> commit # was the one I had found the first time.
>
> 4.  To see if I am totally incompetent, I used git to checkout the
> version of the sources at the problem commit, and then reverted
> those changes (same method used in step 2).  The kernel built
> and ran just fine:  no freeze, no need for "hpet=disabled".

can you post /proc/iomem?

YH
