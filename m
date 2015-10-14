From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Wed, 14 Oct 2015 16:22:03 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1510141620320.3785@nanos>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com> <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com> <20151013045832.GA2437@netboy> <alpine.DEB.2.11.1510130944520.6097@nanos> <20151013083113.GA1931@localhost.localdomain>
 <alpine.DEB.2.11.1510132113470.25029@nanos> <20151013211224.GA19242@netboy> <alpine.DEB.2.11.1510140920200.25029@nanos> <20151014092923.GA23870@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	john.stultz@linaro.org, peterz@infradead.org, x86@kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin.b.stanton@intel.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151014092923.GA23870@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 14 Oct 2015, Richard Cochran wrote:

> On Wed, Oct 14, 2015 at 09:21:42AM +0200, Thomas Gleixner wrote:
> > The firmware gives you an ART/audio timestamp pair. The firmware does
> > neither know about system time nor about PTP time.
> > 
> > So we have to do correlation in software.
> 
> Ok, so give me the ART/audio and two recent ART/ptp times* spaced one
> second apart, then I'll tell you audio/ptp with error well under 1 PPM.
> No need to change the firmware.
> 
> Who cares about the system time?  If the DSP isn't using it, then just
> leave it out of the equation.

It's not only the DSP. There is a bunch of usre space software
involved as well. Care to think about the full picture and not just
about some randomly chosen single problem out of the full problem
space.

Thanks,

	tglx
