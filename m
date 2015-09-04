From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v3 1/4] Add correlated clocksource deriving system time
 from an auxiliary clocksource
Date: Fri, 4 Sep 2015 17:17:43 +0200
Message-ID: <20150904151743.GB16862@localhost.localdomain>
References: <1440183128-1384-1-git-send-email-christopher.s.hall@intel.com>
 <1440183128-1384-2-git-send-email-christopher.s.hall@intel.com>
 <alpine.DEB.2.11.1508222143530.3873@nanos>
 <B79D786B7111A34A8CF09F833429C493A90B2D1F@ORSMSX109.amr.corp.intel.com>
 <alpine.DEB.2.11.1509041438520.15006@nanos>
 <20150904151021.GF18489@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	"Hall, Christopher S" <christopher.s.hall@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"hpa@zytor.com" <hpa@zytor.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150904151021.GF18489@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 04, 2015 at 05:10:21PM +0200, Peter Zijlstra wrote:
> I think what they're getting at is asking if there's a rate limit to
> time adjustments, without that, saving the last n transition points will
> still not cover any given length of history.

As if the ntp code isn't complex enough already - now we're adding
sample histories and adjustment rating limiting?

And all for some unknown DSP in a mythical sound card??


Thanks,
Richard
