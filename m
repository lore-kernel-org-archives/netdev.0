From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v3] Add support for driver cross-timestamp to
 PTP_SYS_OFFSET ioctl
Date: Thu, 9 Jul 2015 16:57:48 +0200
Message-ID: <20150709145748.GC3243@netboy>
References: <1436388401-32168-1-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tglx@linutronix.de, john.stultz@linaro.org, john.ronciak@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Christopher Hall <christopher.s.hall@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:33812 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751154AbbGIO5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 10:57:53 -0400
Content-Disposition: inline
In-Reply-To: <1436388401-32168-1-git-send-email-christopher.s.hall@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 08, 2015 at 01:46:41PM -0700, Christopher Hall wrote:
> This patch allows system and device time ("cross-timestamp") to be
> performed by the driver. Currently, the cross-timestamping is performed
> in the PTP_SYS_OFFSET ioctl.  The PTP clock driver reads gettimeofday()
> and the gettime64() callback provided by the driver. The cross-timestamp
> is best effort where the latency between the capture of system time
> (getnstimeofday()) and the device time (driver callback) may be
> significant.

The interface looks okay to me.  Now all we need is a user of it...

Acked-by: Richard Cochran <richardcochran@gmail.com>
