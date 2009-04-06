From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: sky2: early oops in pci_vpd_truncate
Date: Mon, 6 Apr 2009 11:29:17 -0700
Message-ID: <20090406112917.54c864ee@hobbes>
References: <1238803819.3893.3.camel@brick>
	<20090403180306.44de0324@hobbes>
	<1238815934.3893.4.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-mail-107.bluehost.com ([69.89.22.7]:46419 "HELO
	outbound-mail-107.bluehost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751855AbZDFSgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 14:36:04 -0400
In-Reply-To: <1238815934.3893.4.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 03 Apr 2009 20:32:14 -0700
Harvey Harrison <harvey.harrison@gmail.com> wrote:

> On Fri, 2009-04-03 at 18:03 -0700, Jesse Barnes wrote:
> > On Fri, 03 Apr 2009 17:10:19 -0700
> > Harvey Harrison <harvey.harrison@gmail.com> wrote:
> > 
> > > Hi Stephen,
> > > 
> > > I'm seeing an early oops in current Linus -git right after
> > > sky2_probe unfortunately it scrolls away too fast to get it all,
> > > but after a delayed-printk boot it appears to be a NULL
> > > dereference in pci_vpd_truncate.  sysfs also features prominantly
> > > in the backtrace.. is this a known issue?
> > > 
> > > I see there were some sky2 patches this cycle using the vpd
> > > functions, any pointers/patches to try out?
> > 
> > Yeah there's a patch for that in my queue (not pushed to Linus yet
> > though), subject "[PATCH] PCI: Fix oops in pci_vpd_truncate" from
> > Anton Vorontsov.
> > 
> 
> What tree is that?

git://git.kernel.org/pub/scm/linux/kernel/git/jbarnes/pci-2.6.git.
It'll be in my for-linus branch as soon as I push it out later today.
I'll probably ask Linus to pick it up later this week.

Thanks,
-- 
Jesse Barnes, Intel Open Source Technology Center
