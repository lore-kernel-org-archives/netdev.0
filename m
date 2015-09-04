From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v3 1/4] Add correlated clocksource deriving system time
 from an auxiliary clocksource
Date: Fri, 4 Sep 2015 17:32:05 +0200
Message-ID: <20150904153205.GA17151@localhost.localdomain>
References: <1440183128-1384-1-git-send-email-christopher.s.hall@intel.com>
 <1440183128-1384-2-git-send-email-christopher.s.hall@intel.com>
 <alpine.DEB.2.11.1508222143530.3873@nanos>
 <B79D786B7111A34A8CF09F833429C493A90B2D1F@ORSMSX109.amr.corp.intel.com>
 <alpine.DEB.2.11.1509041438520.15006@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Hall, Christopher S" <christopher.s.hall@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"hpa@zytor.com" <hpa@zytor.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"peterz@infradead.org" <peterz@infradead.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1509041438520.15006@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 04, 2015 at 03:02:19PM +0200, Thomas Gleixner wrote:
> No. This function is explicitely for the precise timestamp usecase,
> which is required by PTP and other sane use cases.

Right.  The audio department only needs to know the (ART, ptp) offset.
The kernel and user space never need the (ART, mediaclock) offset.
That is private information for the DSP.

As long as user space reads (ART, ptp) and provides this regulary to
the audio DSP, then the DSP will have all the information it needs to
figure out (ptp, mediaclock).

Thanks,
Richard
