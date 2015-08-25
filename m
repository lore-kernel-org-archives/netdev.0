From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v3 3/4] Add support for driver cross-timestamp to
 PTP_SYS_OFFSET ioctl
Date: Tue, 25 Aug 2015 09:31:11 +0200
Message-ID: <20150825073111.GB2016@localhost.localdomain>
References: <1440183128-1384-1-git-send-email-christopher.s.hall@intel.com>
 <1440183128-1384-4-git-send-email-christopher.s.hall@intel.com>
 <alpine.DEB.2.11.1508222226540.3873@nanos>
 <20150822211718.GA8561@netboy>
 <alpine.DEB.2.11.1508231011360.3873@nanos>
 <20150823112556.GA8569@localhost.localdomain>
 <B79D786B7111A34A8CF09F833429C493A90AD3C6@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"hpa@zytor.com" <hpa@zytor.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"peterz@infradead.org" <peterz@infradead.org>
To: "Hall, Christopher S" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <B79D786B7111A34A8CF09F833429C493A90AD3C6@ORSMSX109.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 24, 2015 at 08:16:51PM +0000, Hall, Christopher S wrote:
> 
> This means: remove code changes from the PTP_SYS_OFFSET ioctl and call getsynctime64() from a new ioctl PTP_SYS_OFFSET_PRECISE.  Right?

Yes.
 
> And use the same type (struct ptp_sys_offset) for the new ioctl?  Or should a new simplified struct be used? Such as:
> 
> struct precise_ptp_sys_offset {
> 	struct ptp_clock_time device;
> 	struct ptp_clock_time system;
> };

I don't have a strong preference either way.  I would not mind reusing
the existing struct.

> Does it make sense to keep the "cross-timestamp" capabilities flag as-is?

Yes, indeed.
 

Thanks,
Richard
