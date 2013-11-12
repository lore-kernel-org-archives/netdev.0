From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] ipvs: Remove unused variable ret from
	sync_thread_master()
Date: Tue, 12 Nov 2013 17:26:34 +0100
Message-ID: <20131112162634.GB29065@redhat.com>
References: <1384264396-14550-1-git-send-email-geert@linux-m68k.org> <20131112141314.GQ5056@laptop.programming.kicks-ass.net> <AE90C24D6B3A694183C094C60CF0A2F6026B7405@saturn3.aculab.com> <20131112143152.GS5056@laptop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Ingo Molnar <mingo@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131112143152.GS5056@laptop.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/12, Peter Zijlstra wrote:
>
> On Tue, Nov 12, 2013 at 02:21:39PM -0000, David Laight wrote:
> >
> >     /* Tell scheduler we are going to sleep... */
> >     if (signal_pending(current))
> >         /* We don't want waking immediately (again) */
> >         sleep_state = TASK_UNINTERRUPTIBLE;
> >     else
> >         sleep_state = TASK_INTERRUPTIBLE;
> >     set_current_state(sleep_state);
>
> If this is for kernel threads, I think you can wipe the pending state;

Yes, unless this kthread does allow_signal() signal_pending() can't be
true.

Oleg.
