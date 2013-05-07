From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 00/10] optimize freezing tasks by reducing task wakeups
Date: Tue, 7 May 2013 11:12:37 -0700
Message-ID: <20130507181237.GE5531@mtj.dyndns.org>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Pavel Machek <pavel@ucw.cz>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mandeep Singh Baines <msb@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>, linux-nfs@vger.kernel.org,
	linux-pm@vger.kernel.org, netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Colin Cross <ccross@android.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1367884221-20462-1-git-send-email-ccross@android.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Mon, May 06, 2013 at 04:50:05PM -0700, Colin Cross wrote:
> On slow cpus the large number of task wakeups and context switches
> triggered by freezing and thawing tasks can take a significant amount
> of cpu time.  This patch series reduces the amount of work done during
> freezing tasks by avoiding waking up tasks that are already in a freezable
> state.

For the whole series,

 Acked-by: Tejun Heo <tj@kernel.org>

Thanks a lot!

-- 
tejun
