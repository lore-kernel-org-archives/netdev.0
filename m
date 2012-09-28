From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [PATCH RFC net-next 1/1] ptp: add an ioctl to compare PHC time
 with system time
Date: Fri, 28 Sep 2012 09:53:03 +0200
Message-ID: <20120928075303.GB29438@localhost>
References: <cover.1348768886.git.richardcochran@gmail.com>
 <f0c20e2d1a303b0247b1e0e0def19f131de162ff.1348768886.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	John Stultz <john.stultz@linaro.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48097 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752619Ab2I1Hx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2012 03:53:58 -0400
Content-Disposition: inline
In-Reply-To: <f0c20e2d1a303b0247b1e0e0def19f131de162ff.1348768886.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 27, 2012 at 08:12:16PM +0200, Richard Cochran wrote:
> This patch adds an ioctl for PTP Hardware Clock (PHC) devices that allows
> user space to measure the time offset between the PHC and the system
> clock. Rather than hard coding any kind of estimation algorithm into the
> kernel, this patch takes the more flexible approach of just delivering
> an array of raw clock readings. In that way, the user space clock servo
> may be adapted to new and different hardware clocks.

Would it make sense to extend the ioctl to allow also comparing the
PHC with another PHC or perhaps even a different system clock than
CLOCK_REALTIME?

I'm thinking if someone wanted to synchronize one PHC to another, it
should be better to work with phc1-phc2 offsets than combine phc1-sys
and sys-phc2 offsets.

-- 
Miroslav Lichvar
