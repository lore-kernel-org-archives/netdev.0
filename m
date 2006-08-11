From: jschopp <jschopp@austin.ibm.com>
Subject: Re: [PATCH 0/4]:  powerpc/cell spidernet ethernet driver fixes
Date: Fri, 11 Aug 2006 12:42:39 -0500
Message-ID: <44DCC18F.3030201@austin.ibm.com>
References: <20060811170337.GH10638@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:8893 "EHLO e36.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S932256AbWHKRm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 13:42:58 -0400
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20060811170337.GH10638@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> The following series of patches implement some fixes and performance
> improvements for the Spedernet ethernet device driver. The high point
> of the patch series is some code to implement a low-watermark interrupt
> on the transmit queue. The bundle of patches raises transmit performance 
> from some embarassingly low value to a reasonable 730 Megabits per
> second for 1500 byte packets.
> 
> Please note that the spider is an ethernet controller that is 
> integrated into the south bridge, and is thus available only on
> Cell-based platforms.
> 
> These have been well-tested over the last few weeks. Please apply. 

With these patches the spidernet driver performance goes from bad to usable.  They are all 
good changes.  I'd expect some more bottlnecks to be identified now that these are 
cleared.  Maybe Jim and Linas can get the driver performance up from usable to good next.

Acked-by: Joel Schopp <jschopp@austin.ibm.com>
