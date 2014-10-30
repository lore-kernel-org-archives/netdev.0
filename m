From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH 2/5] stmmac: pci: use managed resources
Date: Thu, 30 Oct 2014 10:05:49 +0200
Message-ID: <1414656349.2396.70.camel@linux.intel.com>
References: <1413909333-16380-1-git-send-email-andriy.shevchenko@linux.intel.com>
	 <1413909333-16380-3-git-send-email-andriy.shevchenko@linux.intel.com>
	 <5446C827.2040801@cogentembedded.com>
	 <1413966993.2396.26.camel@linux.intel.com> <544E6486.6040502@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>,
	Rayagond K <rayagond@vayavyalabs.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4730 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757587AbaJ3IG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 04:06:59 -0400
In-Reply-To: <544E6486.6040502@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-10-27 at 16:28 +0100, Giuseppe CAVALLARO wrote:
> On 10/22/2014 10:36 AM, Andy Shevchenko wrote:
> > So, I was trying to find any specification on public regarding to boards
> > that have this IP, no luck so far. I guess that that code was created
> > due to XILINX FPGA usage which probably can provide any BAR user wants
> > to. Thus, I imply that in real applications the BAR most probably will
> > be 0. However, I left variable which can be overridden in future
> > (regarding to PCI ID).
> >
> > It would be nice to hear someone from ST about this. Giuseppe?
> 
> Hello Andy
> 
> this chip is on ST SoCs since long time but embedded. I have no PCI
> card. Added Rayagond on copy too

Rayagond, what do you think about changing an approach that is used to
get resources from PCI?

-- 
Andy Shevchenko <andriy.shevchenko@intel.com>
Intel Finland Oy
