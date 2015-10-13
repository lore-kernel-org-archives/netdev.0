From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Tue, 13 Oct 2015 21:15:51 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1510132113470.25029@nanos>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com> <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com> <20151013045832.GA2437@netboy> <alpine.DEB.2.11.1510130944520.6097@nanos>
 <20151013083113.GA1931@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	john.stultz@linaro.org, peterz@infradead.org, x86@kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin.b.stanton@intel.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151013083113.GA1931@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Oct 2015, Richard Cochran wrote:

> On Tue, Oct 13, 2015 at 09:51:02AM +0200, Thomas Gleixner wrote:
> > 
> > You are restricting the problem space to this particular use
> > case. There are other use cases where PTP is not available or not the
> > relevant reference, but you still want to correlate time domains to
> > ART.
> 
> They may well be other use cases, but they have not been identified
> here.  The PTP to media clock problem has a very simple solution.  You
> do not need a history of system time stamps to solve it.

Well, these use cases are not in the focus of Christopher, but I have
a few in my head. Think industrial fieldbusses.
 
> Even if you wanted to correlate the system time's UTC with the media
> clock, still you don't need any shadow history for that.  Just feed
> (ART, UTC) pairs into the DSP at a regular rate, and let the DSP do
> the math.  This does not need to be part of the central time keeping
> code at all.

That's not working. The firmware is not going to change, no matter
what.

Thanks,

	tglx
