From: "Hall, Christopher S" <christopher.s.hall@intel.com>
Subject: RE: [PATCH v3] Add support for driver cross-timestamp to
 PTP_SYS_OFFSET ioctl
Date: Tue, 14 Jul 2015 01:51:14 +0000
Message-ID: <B79D786B7111A34A8CF09F833429C493A907F200@ORSMSX109.amr.corp.intel.com>
References: <1436388401-32168-1-git-send-email-christopher.s.hall@intel.com>
 <20150709145748.GC3243@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "tglx@linutronix.de" <tglx@linutronix.de>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150709145748.GC3243@netboy>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am assuming the patch is rejected at this point.  I will re-submit later as soon as I am able to post a full end to end solution.

Chris

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Thursday, July 09, 2015 7:58 AM
> To: Hall, Christopher S
> Cc: tglx@linutronix.de; john.stultz@linaro.org; Ronciak, John; linux-
> kernel@vger.kernel.org; netdev@vger.kernel.org
> Subject: Re: [PATCH v3] Add support for driver cross-timestamp to
> PTP_SYS_OFFSET ioctl
> 
> On Wed, Jul 08, 2015 at 01:46:41PM -0700, Christopher Hall wrote:
> > This patch allows system and device time ("cross-timestamp") to be
> > performed by the driver. Currently, the cross-timestamping is performed
> > in the PTP_SYS_OFFSET ioctl.  The PTP clock driver reads gettimeofday()
> > and the gettime64() callback provided by the driver. The cross-timestamp
> > is best effort where the latency between the capture of system time
> > (getnstimeofday()) and the device time (driver callback) may be
> > significant.
> 
> The interface looks okay to me.  Now all we need is a user of it...
> 
> Acked-by: Richard Cochran <richardcochran@gmail.com>
