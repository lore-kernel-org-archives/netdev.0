From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: WARNING: at net/core/neighbour.c:1545 neigh_table_init()
Date: Mon, 11 Feb 2013 21:51:09 +0800
Message-ID: <20130211135109.GA17277@localhost>
References: <20130209123937.GA23420@localhost>
 <20130211092600.GB23932@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130211092600.GB23932@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 11, 2013 at 10:26:00AM +0100, Ingo Molnar wrote:
> 
> * Fengguang Wu <fengguang.wu@intel.com> wrote:
> 
> > Greetings,
> > 
> > I got the below oops in linux-next and the first bad commit is
> > 
> > commit 455e987c0c2eb2c9045dc854559474cf41509965
> > Merge: 7c17e48 fd6da69
> > Author: Linus Torvalds <torvalds@linux-foundation.org>
> > Date:   Sat Dec 1 13:07:48 2012 -0800
> > 
> >     Merge branch 'perf-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
> 
> This bisection result is probably spurious?

You are right. Sorry! I just fixed a recently introduced bug in the
test script and it probably lead to the wrong bisect.

I've restarted the bisect and the initial steps till now are already
different from that of the previous bisect.

Thanks,
Fengguang
