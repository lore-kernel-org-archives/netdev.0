From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] Fix build error caused by broken PCH_PTP module
 dependency.
Date: Wed, 03 Oct 2012 20:43:36 -0400 (EDT)
Message-ID: <20121003.204336.1981040659629176119.davem@davemloft.net>
References: <50654A62.5090003@linux.intel.com>
	<20121002.222238.1580734803370802133.davem@davemloft.net>
	<1349300710.2763.8.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haicheng.li@linux.intel.com, netdev@vger.kernel.org,
	tshimizu818@gmail.com, linux-kernel@vger.kernel.org,
	haicheng.lee@gmail.com
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349300710.2763.8.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 3 Oct 2012 22:45:10 +0100

> I thought of it as being a peripheral feature (which most Solarflare
> hardware doesn't implement) so it made sense for SFC_PTP to be optional
> like SFC_MTD and so on.  But I'm quite happy to use a select instead, if
> you want that to be the convention for all drivers implementing PHC.

I think that consistency might trump those conerns you mentioned, at
least in this case.
