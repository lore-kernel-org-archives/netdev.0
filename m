From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Wed, 14 Oct 2015 11:29:23 +0200
Message-ID: <20151014092923.GA23870@localhost.localdomain>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com>
 <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com>
 <20151013045832.GA2437@netboy>
 <alpine.DEB.2.11.1510130944520.6097@nanos>
 <20151013083113.GA1931@localhost.localdomain>
 <alpine.DEB.2.11.1510132113470.25029@nanos>
 <20151013211224.GA19242@netboy>
 <alpine.DEB.2.11.1510140920200.25029@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	john.stultz@linaro.org, peterz@infradead.org, x86@kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin.b.stanton@intel.com
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1510140920200.25029@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 14, 2015 at 09:21:42AM +0200, Thomas Gleixner wrote:
> The firmware gives you an ART/audio timestamp pair. The firmware does
> neither know about system time nor about PTP time.
> 
> So we have to do correlation in software.

Ok, so give me the ART/audio and two recent ART/ptp times* spaced one
second apart, then I'll tell you audio/ptp with error well under 1 PPM.
No need to change the firmware.

Who cares about the system time?  If the DSP isn't using it, then just
leave it out of the equation.

Thanks,
Richard

* If the audio clock isn't locked to the ART, then I'll need two samples.
