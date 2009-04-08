From: Ingo Molnar <mingo@elte.hu>
Subject: Re: sky2: early oops in pci_vpd_truncate
Date: Wed, 8 Apr 2009 14:00:05 +0200
Message-ID: <20090408120005.GB768@elte.hu>
References: <1238803819.3893.3.camel@brick> <20090403180306.44de0324@hobbes> <1238815934.3893.4.camel@brick> <20090406112917.54c864ee@hobbes> <1239054120.13299.0.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:44324 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933395AbZDHMAU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2009 08:00:20 -0400
Content-Disposition: inline
In-Reply-To: <1239054120.13299.0.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Harvey Harrison <harvey.harrison@gmail.com> wrote:

> On Mon, 2009-04-06 at 11:29 -0700, Jesse Barnes wrote:
> > On Fri, 03 Apr 2009 20:32:14 -0700
> > Harvey Harrison <harvey.harrison@gmail.com> wrote:
> > 
> > > On Fri, 2009-04-03 at 18:03 -0700, Jesse Barnes wrote:
> > > > On Fri, 03 Apr 2009 17:10:19 -0700
> > > > Harvey Harrison <harvey.harrison@gmail.com> wrote:
> > > > 
> > > > > Hi Stephen,
> > > > > 
> > > > > I'm seeing an early oops in current Linus -git right after
> > > > > sky2_probe unfortunately it scrolls away too fast to get it all,
> > > > > but after a delayed-printk boot it appears to be a NULL
> > > > > dereference in pci_vpd_truncate.  sysfs also features prominantly
> > > > > in the backtrace.. is this a known issue?
> > > > > 
> > > > > I see there were some sky2 patches this cycle using the vpd
> > > > > functions, any pointers/patches to try out?
> > > > 
> > > > Yeah there's a patch for that in my queue (not pushed to Linus yet
> > > > though), subject "[PATCH] PCI: Fix oops in pci_vpd_truncate" from
> > > > Anton Vorontsov.
> > > > 
> > > 
> > > What tree is that?
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/jbarnes/pci-2.6.git.
> > It'll be in my for-linus branch as soon as I push it out later today.
> > I'll probably ask Linus to pick it up later this week.
> > 
> 
> Looks like Ingo hit the same oops as well. CC'd.

I still have the revert - can i revert the revert from -tip now, 
it's all fixed in .30-rc1, right?

	Ingo
