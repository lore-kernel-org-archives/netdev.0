From: "Hall, Christopher S" <christopher.s.hall@intel.com>
Subject: RE: [PATCH v3 1/4] Add correlated clocksource deriving system time
 from an auxiliary clocksource
Date: Fri, 4 Sep 2015 21:12:47 +0000
Message-ID: <B79D786B7111A34A8CF09F833429C493A90B2FF7@ORSMSX109.amr.corp.intel.com>
References: <1440183128-1384-1-git-send-email-christopher.s.hall@intel.com>
 <1440183128-1384-2-git-send-email-christopher.s.hall@intel.com>
 <alpine.DEB.2.11.1508222143530.3873@nanos>
 <B79D786B7111A34A8CF09F833429C493A90B2D1F@ORSMSX109.amr.corp.intel.com>
 <20150904081122.GA4201@netboy>
 <20150904142827.GE18489@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"hpa@zytor.com" <hpa@zytor.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Peter Zijlstra <peterz@infradead.org>,
	Richard Cochran <richardcochran@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150904142827.GE18489@twins.programming.kicks-ass.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Peter Zijlstra [mailto:peterz@infradead.org]
> Sent: Friday, September 04, 2015 7:28 AM
> To: Richard Cochran
> Cc: Hall, Christopher S; Thomas Gleixner; Kirsher, Jeffrey T;
> hpa@zytor.com; mingo@redhat.com; john.stultz@linaro.org; x86@kernel.org;
> linux-kernel@vger.kernel.org; netdev@vger.kernel.org; intel-wired-
> lan@lists.osuosl.org
> Subject: Re: [PATCH v3 1/4] Add correlated clocksource deriving system time
> from an auxiliary clocksource
> 
> > > (several milliseconds) and the result will be out of date by some
> fraction of that
> > > amount.
> >
> > Why does it take milliseconds to read one audio time stamp?
> 
> So what I suspect, but please correct me if I'm wrong Chris, is that a
> DSP will buffer and process audio signals, and only later wake up the
> main CPU.
> 
> So by the time the CPU is made aware of the data, it's 'old'.

That's about right.  The DSP runs on a 1 ms cadence.  Any access to registers controlled by the DSP will take 1-2 DSP ticks to access.
