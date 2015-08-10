From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 3/4] Add support for driver cross-timestamp to
 PTP_SYS_OFFSET ioctl
Date: Mon, 10 Aug 2015 10:53:10 +0200
Message-ID: <20150810085310.GB18566@localhost.localdomain>
References: <1438988495-9942-1-git-send-email-christopher.s.hall@intel.com>
 <1438988495-9942-4-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.stultz@linaro.org, tglx@linutronix.de, mingo@redhat.com,
	jeffrey.t.kirsher@intel.com, john.ronciak@intel.com, hpa@zytor.com,
	x86@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Christopher Hall <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1438988495-9942-4-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 07, 2015 at 04:01:34PM -0700, Christopher Hall wrote:
> This patch allows system and device time ("cross-timestamp") to be
> performed by the driver. Currently, the cross-timestamping is performed
> in the PTP_SYS_OFFSET ioctl.  The PTP clock driver reads gettimeofday()
> and the gettime64() callback provided by the driver. The cross-timestamp
> is best effort where the latency between the capture of system time
> (getnstimeofday()) and the device time (driver callback) may be
> significant.

Acked-by: Richard Cochran <richardcochran@gmail.com>
