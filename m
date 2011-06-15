From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [stable] Please revert "iwlagn: Support new 5000 microcode."
 from 2.6.32 and 2.6.33
Date: Wed, 15 Jun 2011 07:57:32 +0200
Message-ID: <20110615055731.GB2214@redhat.com>
References: <20110613181317.GA3385@herton-IdeaPad-Y430>
 <20110614230344.GA2065@kroah.com>
 <20110615011443.GA13680@herton-IdeaPad-Y430>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, stable@linux.kernel.org,
	donald.h.fry@intel.com, reinette.chatre@intel.com,
	wey-yi.w.guy@intel.com, ilw@linux.intel.com,
	linville@tuxdriver.com, ak@linux.intel.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18544 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116Ab1FOF5W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2011 01:57:22 -0400
Content-Disposition: inline
In-Reply-To: <20110615011443.GA13680@herton-IdeaPad-Y430>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 14, 2011 at 10:14:44PM -0300, Herton Ronaldo Krzesinski wrote:
> On Tue, Jun 14, 2011 at 04:03:44PM -0700, Greg KH wrote:
> > On Mon, Jun 13, 2011 at 03:13:18PM -0300, Herton Ronaldo Krzesinski wrote:
> > > The patch ("iwlagn: Support new 5000 microcode") shoudn't have been
> > > applied on 2.6.32 and 2.6.33 stable trees, it doesn't support new
> > > firmware file format, thus if the new firmware is on the disk, loading
> > > fails, as reported on:
> > > https://bugs.launchpad.net/ubuntu/+source/linux/+bug/796336
> > > 
> > > Support for the iwlagn new firmware file format was only added beginning
> > > with 2.6.35 (commit "iwlagn: implement loading a new firmware file
> > > type"), so iwlagn works with new firmware only with 2.6.35 or later.
> > 
> > Can I get an ack from the developer of the patch and the people involved
> > with it first?  It was asked to be backported for a reason, so I would
> > at least like to get the people who asked for the backport to have a
> > chance to respond please.
> > 
> > It's only nice, why would you exclude them?
> 
> I didn't intend to exclude anyone and I'm just reporting it, it didn't
> came to my mind CC'ing people while sending to stable, and hopefully
> everyone related are CC'ed now.
> 
> Also note that this revert request is for 2.6.32 and 2.6.33 *only*
> 
> And seems the right thing to do for them.
> 
> The other stable release where this was applied (2.6.35) looks fine
> but these two are too old to support the new firmware (don't work, need
> extra patches backported which weren't, like the commit I mentioned --
> commit "iwlagn: implement loading a new firmware file type"), as yourself
> can check reading the code/bug report, and what I wrote.

ACK for revert. I could be wrong, but I think some more patches, except mentioned
new format patch, are needed to make driver work reliably with the new firmware.

Stanislaw
