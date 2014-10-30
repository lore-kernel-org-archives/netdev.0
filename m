From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH 0/5] stmmac: pci: various cleanups and fixes
Date: Thu, 30 Oct 2014 11:41:41 +0200
Message-ID: <1414662101.2396.72.camel@linux.intel.com>
References: <1413909333-16380-1-git-send-email-andriy.shevchenko@linux.intel.com>
	 <5451F32C.8060403@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15807 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757246AbaJ3JmC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 05:42:02 -0400
In-Reply-To: <5451F32C.8060403@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-30 at 09:13 +0100, Giuseppe CAVALLARO wrote:
> On 10/21/2014 6:35 PM, Andy Shevchenko wrote:
> > There are few cleanups and fixes regarding to stmmac PCI driver.
> > This has been tested on Intel Galileo board with 3.18-rc1 kernel.
> 
> Hello Andy,
> 
> for your next version I think that the patches should be for net-next
> tree.
> Maybe the following for net.git: "stmmac: pci: set default filter bins"
> 
> I kindly ask you to detail fix and cleanup.

I just send the fix as a separate patch.

I'm going to reshuffle the others and maybe introduce few more. I would
like to get this soon since it would be a good base to go with Quark
support further.

> 
> peppe
> 
> >
> > Andy Shevchenko (5):
> >    stmmac: pci: convert to use dev_pm_ops
> >    stmmac: pci: use managed resources
> >    stmmac: pci: convert to use dev_* macros
> >    stmmac: pci: set default filter bins
> >    stmmac: pci: remove FSF address
> >
> >   drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 92 ++++++++----------------
> >   1 file changed, 30 insertions(+), 62 deletions(-)
> >
> 


-- 
Andy Shevchenko <andriy.shevchenko@intel.com>
Intel Finland Oy
