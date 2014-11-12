From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH 2/5] stmmac: pci: use managed resources
Date: Wed, 12 Nov 2014 11:28:42 +0200
Message-ID: <1415784522.9814.7.camel@linux.intel.com>
References: <1413909333-16380-1-git-send-email-andriy.shevchenko@linux.intel.com>
	 <1413909333-16380-3-git-send-email-andriy.shevchenko@linux.intel.com>
	 <5446C827.2040801@cogentembedded.com>
	 <1413966993.2396.26.camel@linux.intel.com> <544E6486.6040502@st.com>
	 <1414656349.2396.70.camel@linux.intel.com>
	 <CAJ3bTp79FLhOCvvQNG=+C17v5TOzy2ZvbyC24OQWTr2mmJ4OCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev <netdev@vger.kernel.org>,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
To: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:22286 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752705AbaKLJ2m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2014 04:28:42 -0500
In-Reply-To: <CAJ3bTp79FLhOCvvQNG=+C17v5TOzy2ZvbyC24OQWTr2mmJ4OCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-11-12 at 10:44 +0530, Rayagond Kokatanur wrote:
> Hi Andy,
> 
> Yes, I tested this pci driver on XILINX FPGA setup and its true that
> we can man any bar number by changing the configuration in bit-map.
> 
> But its always good to keep that for loop which try to map any bar
> number between 0 - 5, the new code breaks if bar number is other than
> zero.
> 
> We can make driver generic by keeping that loop.

Thanks for clarification, I had redone this in v2 which is applied.

> 
> wwr
> Rayagond
> 
> On Thu, Oct 30, 2014 at 1:35 PM, Andy Shevchenko
> <andriy.shevchenko@linux.intel.com> wrote:
> > On Mon, 2014-10-27 at 16:28 +0100, Giuseppe CAVALLARO wrote:
> >> On 10/22/2014 10:36 AM, Andy Shevchenko wrote:
> >> > So, I was trying to find any specification on public regarding to boards
> >> > that have this IP, no luck so far. I guess that that code was created
> >> > due to XILINX FPGA usage which probably can provide any BAR user wants
> >> > to. Thus, I imply that in real applications the BAR most probably will
> >> > be 0. However, I left variable which can be overridden in future
> >> > (regarding to PCI ID).
> >> >
> >> > It would be nice to hear someone from ST about this. Giuseppe?
> >>
> >> Hello Andy
> >>
> >> this chip is on ST SoCs since long time but embedded. I have no PCI
> >> card. Added Rayagond on copy too
> >
> > Rayagond, what do you think about changing an approach that is used to
> > get resources from PCI?
> >
> > --
> > Andy Shevchenko <andriy.shevchenko@intel.com>
> > Intel Finland Oy
> >


-- 
Andy Shevchenko <andriy.shevchenko@intel.com>
Intel Finland Oy
