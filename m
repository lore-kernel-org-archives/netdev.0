From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Wed, 14 Oct 2015 09:21:42 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1510140920200.25029@nanos>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com> <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com> <20151013045832.GA2437@netboy> <alpine.DEB.2.11.1510130944520.6097@nanos> <20151013083113.GA1931@localhost.localdomain>
 <alpine.DEB.2.11.1510132113470.25029@nanos> <20151013211224.GA19242@netboy>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	john.stultz@linaro.org, peterz@infradead.org, x86@kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin.b.stanton@intel.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151013211224.GA19242@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Oct 2015, Richard Cochran wrote:
> On Tue, Oct 13, 2015 at 09:15:51PM +0200, Thomas Gleixner wrote:
> > That's not working. The firmware is not going to change, no matter
> > what.
> 
> Can we at least have a explanation of how the firmware operates?  How
> are (ART,sys) pairs are generated, and how they are supposed to get
> into the DSP?

The firmware gives you an ART/audio timestamp pair. The firmware does
neither know about system time nor about PTP time.

So we have to do correlation in software.

Thanks,

	tglx
