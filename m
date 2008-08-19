From: Arthur Jones <ajones@riverbed.com>
Subject: Re: [UPDATED] [NET-NEXT PATCH 3/3] e1000e: add support for new
	82574L part
Date: Tue, 19 Aug 2008 07:24:10 -0700
Message-ID: <20080819142410.GA7100@ajones-laptop.nbttech.com>
References: <20080814003759.17449.58830.stgit@jtkirshe-mobile.jf.intel.com> <20080818160040.GA17369@ajones-laptop.nbttech.com> <9929d2390808181253i55f5a4d0pae07e4a23eaba7d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "jeff@garzik.org" <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	Bruce Allan <bruce.w.allan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.riverbed.com ([206.169.144.7]:45858 "EHLO
	smtp2.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375AbYHSOYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 10:24:14 -0400
Content-Disposition: inline
In-Reply-To: <9929d2390808181253i55f5a4d0pae07e4a23eaba7d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff, ...

On Mon, Aug 18, 2008 at 12:53:06PM -0700, Jeff Kirsher wrote:
> [...]
> > This is perhaps a dup of the e1000.sf.net bug
> > 2040298 against the linux 2.6.26 + 0.4.1.7 intel
> > e1000e driver:
> >
> > http://sourceforge.net/tracker/index.php?func=detail&aid=2040298&group_id=42302&atid=447449
> >
> > The system info is the same as in that bug, only
> > the kernel and driver have changed...
> 
> This is to be expected since these patches get the in kernel driver
> updated or at least close to the out of kernel 0.4.1.7 driver.  We are
> aware of the issue and we are currently working the issue.

Very fast work indeed, yesterday I was given new
firmware and today it looks like the issue is resolved.

> Jesse is expecting to get you a patch today to test which should
> resolve the issue.

Yesterday I received from Intel an upgrade from pre-production
(v0.5) 82574 firmware to production (v1.0) firmware and tools to
install it.  With the upgrade the problem no longer appears to be
reproducible.

Thanks to all at Intel for tracking this issue down and solving
it.  Esp Jesse Brandeburg who kept the e1000.sf.net bug updated
with new things to try and even offered to send along hardware to
help in debugging.  Thanks all!

Arthur
