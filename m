From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] Drop ISA dependencies from IRDA drivers
Date: Thu, 15 Jul 2004 15:35:28 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040715223528.GA4645@bougret.hpl.hp.com>
References: <m34qo96x8m.fsf@averell.firstfloor.org> <40F6B547.7050800@pobox.com> <20040715205001.GA2527@muc.de> <40F6F076.2080001@pobox.com> <20040715215552.GA46635@muc.de>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
	irda-users@lists.sourceforge.net, jt@hpl.hp.com,
	the_nihilant@autistici.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S266427AbUGOWff@vger.kernel.org>
To: Andi Kleen <ak@muc.de>
Content-Disposition: inline
In-Reply-To: <20040715215552.GA46635@muc.de>
List-Id: netdev.vger.kernel.org

On Thu, Jul 15, 2004 at 11:55:52PM +0200, Andi Kleen wrote:
> 
> Anyways, this is only tangential to the original reason for the patch.
> Can you please drop the bogus ISA dependencies. Jean has clearly stated
> that the drivers have nothing to do with ISA itself.

	Andy, I never said that, please quote me accurately. I
personally don't have strong opinions on whether those drivers should
be tagged with CONFIG_ISA or not, but those hardware are definitely
mapped on the ISA bus.

	Also, I just had a report of an user having a problem with the
removal of isa_virt_to_bus on x86-64 :
		http://bugme.osdl.org/show_bug.cgi?id=3073
	Depending on how this bug pans out, we *may* have to revert
the patch and brings back isa_virt_to_bus.

	Regards,

	Jean
