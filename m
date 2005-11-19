From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [RFC: 2.6 patch] remove drivers/net/eepro100.c
Date: Sat, 19 Nov 2005 21:34:57 +0100
Message-ID: <20051119203457.GL16060@stusta.de>
References: <20051118033302.GO11494@stusta.de> <20051118090158.GA11621@flint.arm.linux.org.uk> <437DFD6C.1020106@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King <rmk+lkml@arm.linux.org.uk>, saw@saw.sw.com.sg,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750812AbVKSUfM@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <437DFD6C.1020106@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 18, 2005 at 11:12:28AM -0500, Jeff Garzik wrote:
> Russell King wrote:
> >On Fri, Nov 18, 2005 at 04:33:02AM +0100, Adrian Bunk wrote:
> >
> >>This patch removes the obsolete drivers/net/eepro100.c driver.
> >>
> >>Is there any reason why it should be kept?
> >
> >
> >Tt's the only driver which works correctly on ARM CPUs.  e100 is
> >basically buggy.  This has been discussed here on lkml and more
> >recently on linux-netdev.  If anyone has any further questions
> >please read the archives of those two lists.
> 
> After reading the archives, one discovers the current status is:
> 
> 	waiting on ARM folks to test e100
> 
> Latest reference is public message-id <4371A373.6000308@pobox.com>, 
> which was CC'd to you.
> 
> There is a patch in netdev-2.6.git#e100-sbit and in Andrew's -mm tree 
> that should solve the ARM problems, and finally allow us to kill 
> eepro100.  But it's waiting for feedback...

I'mn not subscribed to netdev, and 4371A373.6000308@pobox.com was not 
Cc'ed to me, but I do now understand the status of e100/eepro100.

After all my email was just an RFC.

> 	Jeff

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
