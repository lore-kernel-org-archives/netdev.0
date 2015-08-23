From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v3 3/4] Add support for driver cross-timestamp to
 PTP_SYS_OFFSET ioctl
Date: Sun, 23 Aug 2015 13:25:56 +0200
Message-ID: <20150823112556.GA8569@localhost.localdomain>
References: <1440183128-1384-1-git-send-email-christopher.s.hall@intel.com>
 <1440183128-1384-4-git-send-email-christopher.s.hall@intel.com>
 <alpine.DEB.2.11.1508222226540.3873@nanos>
 <20150822211718.GA8561@netboy>
 <alpine.DEB.2.11.1508231011360.3873@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	john.stultz@linaro.org, x86@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, peterz@infradead.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:33845 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbbHWL0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 07:26:03 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1508231011360.3873@nanos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 23, 2015 at 10:15:00AM +0200, Thomas Gleixner wrote:
> So why can't you take N samples from the synced hardware? It does not
> make any sense to me to switch to the imprecise mode if nsamples > 1.

Ok, then I prefer to leave this "imprecise" method in place and ...
 
> You can also provide a new IOCTL PTP_SYS_OFFSET_PRECISE which returns
> -ENOSYS if hardware timestamping is not available and avoid the whole
> nsamples dance for the case where we can get precise timestamps.

have this for the new way.

By keeping the imprecise method, we will be able to run both methods
on the new hardware.  That will help to quantify how imprecise the old
method is.

Thanks,
Richard
