From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [RFC: 2.6 patch] remove drivers/net/tulip/xircom_tulip_cb.c
Date: Sat, 19 Nov 2005 21:43:20 +0100
Message-ID: <20051119204319.GN16060@stusta.de>
References: <20051118033306.GP11494@stusta.de> <437E56EA.8070103@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, tulip-users@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750809AbVKSUnW@vger.kernel.org>
To: Mark Lord <lkml@rtr.ca>
Content-Disposition: inline
In-Reply-To: <437E56EA.8070103@rtr.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 18, 2005 at 05:34:18PM -0500, Mark Lord wrote:
> Adrian Bunk wrote:
> >This patch removes the obsolete drivers/net/tulip/xircom_tulip_cb.c 
> >driver.
> >
> >Is there any reason why it should be kept?
> 
> Yes.  It is the only driver that works
> without lockups on Xircom Cardbus cards.
> Or so has been the case any time I've tried
> the alternatives.
> 
> Is there any good reason to nuke it?

- there's a more recent driver for the same hardware
- the driver uses the deprecated virt_to_bus/bus_to_virt we want to get 
  rid of

Can you give me a pointer to your bug report containing more details 
regarding the problems you had with the xircom_cb driver?

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
