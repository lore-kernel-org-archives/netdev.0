From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH v2 00/10] optimize freezing tasks by reducing task wakeups
Date: Wed, 08 May 2013 02:02:24 +0200
Message-ID: <8514381.qPm240gC5h@vostro.rjw.lan>
References: <1367884221-20462-1-git-send-email-ccross@android.com> <20130507181237.GE5531@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org, Pavel Machek <pavel@ucw.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mandeep Singh Baines <msb@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>, linux-nfs@vger.kernel.org,
	linux-pm@vger.kernel.org, netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Tejun Heo <tj@kernel.org>, Colin Cross <ccross@android.com>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20130507181237.GE5531@mtj.dyndns.org>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, May 07, 2013 11:12:37 AM Tejun Heo wrote:
> Hello,
> 
> On Mon, May 06, 2013 at 04:50:05PM -0700, Colin Cross wrote:
> > On slow cpus the large number of task wakeups and context switches
> > triggered by freezing and thawing tasks can take a significant amount
> > of cpu time.  This patch series reduces the amount of work done during
> > freezing tasks by avoiding waking up tasks that are already in a freezable
> > state.
> 
> For the whole series,
> 
>  Acked-by: Tejun Heo <tj@kernel.org>
> 
> Thanks a lot!

All 16 patches queued up as v3.11 material.

Many thanks to everyone involved,
Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
