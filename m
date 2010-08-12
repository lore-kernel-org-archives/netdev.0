From: Greg KH <gregkh@suse.de>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Wed, 11 Aug 2010 19:04:14 -0700
Message-ID: <20100812020414.GD14121@suse.de>
References: <4C61EDE5.4030505@dsn.okisemi.com>
 <AANLkTinZ510_k2E5JFxa8jcuv8gRABFakyrcfzsg2vm1@mail.gmail.com>
 <D5AB6E638E5A3E4B8F4406B113A5A19A28EA26EB@shsmsx501.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Baluta <daniel.baluta@gmail.com>,
	Masayuki Ohtak <masa-korg@dsn.okisemi.com>,
	"meego-dev@meego.com" <meego-dev@meego.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	"socketcan-core@lists.berlios.de" <socketcan-core@lists.berlios.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Khor, Andrew Chih Howe" <andrew.chih.howe.khor@intel.com>,
	"arjan@linux.intel.com" <arjan@linux.intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>
To: "Wang, Qi" <qi.wang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58076 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933124Ab0HLCHY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Aug 2010 22:07:24 -0400
Content-Disposition: inline
In-Reply-To: <D5AB6E638E5A3E4B8F4406B113A5A19A28EA26EB@shsmsx501.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 12, 2010 at 09:42:27AM +0800, Wang, Qi wrote:
> > -----Original Message-----
> > From: Daniel Baluta [mailto:daniel.baluta@gmail.com]
> > Sent: Wednesday, August 11, 2010 6:37 PM
> > To: Masayuki Ohtak
> > Cc: meego-dev@meego.com; Wolfgang Grandegger;
> > socketcan-core@lists.berlios.de; netdev@vger.kernel.org; Khor, Andrew Chih
> > Howe; gregkh@suse.de; arjan@linux.intel.com; Wang, Qi; Wang, Yong Y
> > Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
> > 
> > Hi,
> > 
> > 2010/8/11 Masayuki Ohtak <masa-korg@dsn.okisemi.com>:
> > > CAN driver of Topcliff PCH
> > >
> > > Topcliff PCH is the platform controller hub that is going to be used in
> > > Intel's upcoming general embedded platform. All IO peripherals in
> > > Topcliff PCH are actually devices sitting on AMBA bus.
> > > Topcliff PCH has CAN I/F. This driver enables CAN function.
> > >
> > > Signed-off-by: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
> > 
> > I have a few questions:
> > 
> > 1. Is your code based on Intel's CAN EP80579 ([1]) ?
> No.
> > 2. Why don't you use kernel existing kfifo infrastructure? ([2]).
> Just take a look at kfifo.h. This structure has been changed. I
> remembered there was a spin_lock from kfifo previously. Currently it's
> been removed, good.
> OKI-sans, would you please take a look at ./include/linux/kfifo.h, and try to use this structure and APIs?
> 
> Daniel,
> 
> We're anxious to integrate those codes now. Perhaps it'll take us
> quite a long time to use kfifo. How about implementing it with the
> next version?

What do you mean by this?  Code isn't merged into the tree unless it is
correct.  Please fix this now, it's not that big of a deal.

> > 3. Can you provide a pointer to Topcliff PCH CAN I/F datasheet ?
> Currently this datasheet isn't open.

Even under NDA?  The Linux foundation offers a service to allow
developers access to data sheets so that they can do kernel development
and code review.

thanks,

greg k-h
