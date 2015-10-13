From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v4 3/4] Add PTP_SYS_OFFSET_PRECISE for driver
 crosstimestamping
Date: Tue, 13 Oct 2015 15:59:26 +0200
Message-ID: <20151013135925.GB5422@localhost.localdomain>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com>
 <1444675522-4198-4-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	tglx@linutronix.de, john.stultz@linaro.org, peterz@infradead.org,
	x86@kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kevin.b.stanton@intel.com
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444675522-4198-4-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 12, 2015 at 11:45:21AM -0700, Christopher S. Hall wrote:
>  
> +struct ptp_sys_offset_precise {
> +	unsigned int rsv[4];    /* Reserved for future use. */
> +	struct ptp_clock_time dev;
> +	struct ptp_clock_time sys;
> +};
> +

Please put the reserved field at the bottom.  Also, since we reading
the raw monotonic time under the hood, we might as well return it in
this struct too.  It costs us almost nothing, and having that value
can be useful for characterizing the system oscillator.

Thanks,
Richard
