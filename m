From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v6 8/9] Add PTP_SYS_OFFSET_PRECISE for driver
 crosstimestamping
Date: Wed, 13 Jan 2016 22:31:56 +0100
Message-ID: <20160113213156.GB20252@localhost.localdomain>
References: <1452687149-11281-1-git-send-email-christopher.s.hall@intel.com>
 <1452687149-11281-9-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tglx@linutronix.de, mingo@redhat.com, john.stultz@linaro.org,
	hpa@zytor.com, jeffrey.t.kirsher@intel.com, x86@kernel.org,
	linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, kevin.b.stanton@intel.com
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452687149-11281-9-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 13, 2016 at 04:12:28AM -0800, Christopher S. Hall wrote:
> Currently, network /system cross-timestamping is performed in the
> PTP_SYS_OFFSET ioctl. The PTP clock driver reads gettimeofday() and
> the gettime64() callback provided by the driver. The cross-timestamp
> is best effort where the latency between the capture of system time
> (getnstimeofday()) and the device time (driver callback) may be
> significant.

Looks good to me.

Acked-by: Richard Cochran <richardcochran@gmail.com>
