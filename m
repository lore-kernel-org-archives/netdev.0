From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Thu, 15 Oct 2015 10:13:36 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1510151007070.3960@nanos>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com> <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com> <20151013045832.GA2437@netboy> <alpine.DEB.2.11.1510130944520.6097@nanos> <20151013083113.GA1931@localhost.localdomain>
 <alpine.DEB.2.11.1510132113470.25029@nanos> <20151013211224.GA19242@netboy> <op.x6iz21fw1774gr@chall-mobl2.amr.corp.intel.com> <20151015054142.GA4784@netboy>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Christopher Hall <christopher.s.hall@intel.com>,
	jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	john.stultz@linaro.org, peterz@infradead.org, x86@kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin.b.stanton@intel.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151015054142.GA4784@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Oct 2015, Richard Cochran wrote:
> Thomas seems to say that there are *other* applications that will want
> to transform device time into system time, but why does your audio
> application use the system time, when the audio-to-ptp time is
> directly available, without any man in the middle?

PTP time is slow to access. Having a correlation to system time makes
a log of things simpler; nanosleep is the most obvious example.

Thanks,

	tglx
