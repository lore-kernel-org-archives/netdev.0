From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Drop ISA dependencies from IRDA drivers
Date: Thu, 15 Jul 2004 12:48:07 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <40F6B547.7050800@pobox.com>
References: <m34qo96x8m.fsf@averell.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, irda-users@lists.sourceforge.net,
	jt@hpl.hp.com, the_nihilant@autistici.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S266241AbUGOQs0@vger.kernel.org>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m34qo96x8m.fsf@averell.firstfloor.org>
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> http://bugme.osdl.org/show_bug.cgi?id=3077
> 
> Some IRDA chipsets currently don't work on x86-64, because
> they're dependent on CONFIG_ISA and x86-64 doesn't set this.
> CONFIG_ISA means real ISA slots, and I doubt these chips
> come on real ISA cards, so I just removed the bogus 
> dependency.

Honestly, the issue and patch need more thought, IMO.

Regardless of theory, CONFIG_ISA is currently also used to indicate 
legacy ISA devices that are today integrated into southbridges.

And with legacy ISA devices still around, I don't see a whole lot of 
value in differentiating between "I have ISA slots" and "I have ISA 
devices".

	Jeff
