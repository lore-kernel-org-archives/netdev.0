From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Drop ISA dependencies from IRDA drivers
Date: Fri, 16 Jul 2004 07:36:52 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040716053652.GA662@wotan.suse.de>
References: <m34qo96x8m.fsf@averell.firstfloor.org> <40F6B547.7050800@pobox.com> <20040715205001.GA2527@muc.de> <40F6F076.2080001@pobox.com> <20040715215552.GA46635@muc.de> <20040715223528.GA4645@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@muc.de>, Jeff Garzik <jgarzik@pobox.com>,
	netdev@oss.sgi.com, irda-users@lists.sourceforge.net,
	the_nihilant@autistici.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S266472AbUGPFgz@vger.kernel.org>
To: jt@hpl.hp.com
Content-Disposition: inline
In-Reply-To: <20040715223528.GA4645@bougret.hpl.hp.com>
List-Id: netdev.vger.kernel.org

On Thu, Jul 15, 2004 at 03:35:28PM -0700, Jean Tourrilhes wrote:
> On Thu, Jul 15, 2004 at 11:55:52PM +0200, Andi Kleen wrote:
> > 
> > Anyways, this is only tangential to the original reason for the patch.
> > Can you please drop the bogus ISA dependencies. Jean has clearly stated
> > that the drivers have nothing to do with ISA itself.
> 
> 	Andy, I never said that, please quote me accurately. I
> personally don't have strong opinions on whether those drivers should
> be tagged with CONFIG_ISA or not, but those hardware are definitely
> mapped on the ISA bus.

More likely on LPC interface.  And not on a ISA slot.

Anyways, if you want them to work on x86-64 you will have to drop
that bogus dependency.  I have no plans to ever define CONFIG_ISA
on x86-64.

-Andi
