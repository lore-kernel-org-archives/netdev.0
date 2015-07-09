From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] Add support for driver cross-timestamp to
 PTP_SYS_OFFSET ioctl
Date: Thu, 09 Jul 2015 15:01:10 -0700 (PDT)
Message-ID: <20150709.150110.1865960968554925450.davem@davemloft.net>
References: <1436388401-32168-1-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, tglx@linutronix.de,
	john.stultz@linaro.org, john.ronciak@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: christopher.s.hall@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45902 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545AbbGIWBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 18:01:11 -0400
In-Reply-To: <1436388401-32168-1-git-send-email-christopher.s.hall@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christopher Hall <christopher.s.hall@intel.com>
Date: Wed,  8 Jul 2015 13:46:41 -0700

> This patch allows system and device time ("cross-timestamp") to be
> performed by the driver. Currently, the cross-timestamping is performed
> in the PTP_SYS_OFFSET ioctl.  The PTP clock driver reads gettimeofday()
> and the gettime64() callback provided by the driver. The cross-timestamp
> is best effort where the latency between the capture of system time
> (getnstimeofday()) and the device time (driver callback) may be
> significant.

Please resubmit this once there is an actual user of this new
facility, not beforehand.

Thank you.
