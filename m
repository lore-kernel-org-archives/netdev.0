From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Tue, 20 Oct 2015 10:54:08 +0200
Message-ID: <20151020085408.GA2542@netboy>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com>
 <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com>
 <alpine.DEB.2.11.1510132116480.25029@nanos>
 <op.x6iyd7gq1774gr@chall-mobl2.amr.corp.intel.com>
 <alpine.DEB.2.11.1510151014330.3960@nanos>
 <op.x6r25dza1774gr@chall-mobl2.amr.corp.intel.com>
 <CALAqxLXu_C8sWaKyxqXJPFV+m5Zdk=4q4s7O6NoLR1B8bbyuxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christopher Hall <christopher.s.hall@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	"x86@kernel.org" <x86@kernel.org>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, kevin.b.stanton@intel.com
To: John Stultz <john.stultz@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALAqxLXu_C8sWaKyxqXJPFV+m5Zdk=4q4s7O6NoLR1B8bbyuxg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 19, 2015 at 05:36:56PM -0700, John Stultz wrote:
> If we're only tracking 4ms of history, how does this solution
> measurably improve the error over using the timestamps to generate
> MONOTONIC_RAW clock deltas (which doesn't require keeping any history)
> and using getnstime_raw_and_real to take an anchor point to calculate
> the delta from?  Why is adding complexity necessary?

This idea is variant of what I suggested in another reply in this
thread.  To my understanding, there is no need at all to keep a
history arbitrarily 4 ms long.  Instead, the DSP driver (or whoever
else may need such a thing) can simply sample the system time at the
rate needed for that particular application.

Thanks,
Richard
