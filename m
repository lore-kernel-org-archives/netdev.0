From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] drivers: ptp: Include new header file in ptp_pch.c
Date: Thu, 19 Dec 2013 20:23:52 +0100
Message-ID: <20131219192352.GA14612@netboy>
References: <1387140255-11797-1-git-send-email-rashika.kheria@gmail.com>
 <20131216085839.GA8303@netboy>
 <20131218.174359.2230195267384857675.davem@davemloft.net>
 <20131219072757.GB4281@netboy>
 <1387480400.1876.32.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, rashika.kheria@gmail.com,
	linux-kernel@vger.kernel.org, dvhart@linux.intel.com,
	joe@perches.com, andriy.shevchenko@linux.intel.com,
	vfalico@redhat.com, netdev@vger.kernel.org, josh@joshtriplett.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1387480400.1876.32.camel@bwh-desktop.uk.level5networks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 19, 2013 at 07:13:20PM +0000, Ben Hutchings wrote:
> 
> PTP is no longer a compile-time option in most net drivers.

Right, for those drivers where there is little or no performance
impact, there is no good reason not to enable the PTP bits.

But if the PTP code entails a run time cost, then we want it to be
optional, but not as a separate module. I suspect that the pch device
falls into this category, but I am not sure without taking another
look.

Thanks,
Richard
