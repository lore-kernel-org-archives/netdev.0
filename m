From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] drivers: ptp: Include new header file in ptp_pch.c
Date: Thu, 19 Dec 2013 19:13:20 +0000
Message-ID: <1387480400.1876.32.camel@bwh-desktop.uk.level5networks.com>
References: <1387140255-11797-1-git-send-email-rashika.kheria@gmail.com>
	 <20131216085839.GA8303@netboy>
	 <20131218.174359.2230195267384857675.davem@davemloft.net>
	 <20131219072757.GB4281@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <rashika.kheria@gmail.com>,
	<linux-kernel@vger.kernel.org>, <dvhart@linux.intel.com>,
	<joe@perches.com>, <andriy.shevchenko@linux.intel.com>,
	<vfalico@redhat.com>, <netdev@vger.kernel.org>,
	<josh@joshtriplett.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131219072757.GB4281@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-12-19 at 08:27 +0100, Richard Cochran wrote:
> On Wed, Dec 18, 2013 at 05:43:59PM -0500, David Miller wrote:
> > 
> > I think this begs an even more fundamental question, why isn't the PTP
> > driver abstraction providing the necessary methods and interfaces so
> > that pch_gbe doesn't have to call into the ptp_pch.c code directly?
> 
> Really it is more of a driver issue. For MAC based PTP clocks, they
> are so tightly coupled to the MAC driver that it is better *not* to
> have the PTP functions in a separate module. Instead, if having the
> PTP stuff optional makes sense, then the PTP parts are just a compile
> time option in the MAC driver. This is how the other MAC drivers with
> optional PTP are structured.
[...]

PTP is no longer a compile-time option in most net drivers.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
