From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Thu, 15 Oct 2015 07:41:43 +0200
Message-ID: <20151015054142.GA4784@netboy>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com>
 <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com>
 <20151013045832.GA2437@netboy>
 <alpine.DEB.2.11.1510130944520.6097@nanos>
 <20151013083113.GA1931@localhost.localdomain>
 <alpine.DEB.2.11.1510132113470.25029@nanos>
 <20151013211224.GA19242@netboy>
 <op.x6iz21fw1774gr@chall-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>, jeffrey.t.kirsher@intel.com,
	hpa@zytor.com, mingo@redhat.com, john.stultz@linaro.org,
	peterz@infradead.org, x86@kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin.b.stanton@intel.com
To: Christopher Hall <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <op.x6iz21fw1774gr@chall-mobl2.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 14, 2015 at 07:34:03PM -0700, Christopher Hall wrote:
> I hope this is helpful. Thanks.

So the DSP does not produce or consume system time stamps. Fine.
Still I fail to understand why you need the system time.

Thomas seems to say that there are *other* applications that will want
to transform device time into system time, but why does your audio
application use the system time, when the audio-to-ptp time is
directly available, without any man in the middle?

Thanks,
Richard
