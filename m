From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [RFC: 2.6 patch] remove drivers/net/eepro100.c
Date: Fri, 18 Nov 2005 16:32:09 +0000
Message-ID: <20051118163208.GA23355@flint.arm.linux.org.uk>
References: <20051118033302.GO11494@stusta.de> <20051118090158.GA11621@flint.arm.linux.org.uk> <437DFD6C.1020106@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@stusta.de>, saw@saw.sw.com.sg,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932400AbVKRQcZ@vger.kernel.org>
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

So what you're saying is that it's down to me to test the thing.

Ok.

I've been extremely patient waiting for e100 to get fixed (it's been
literally _years_), and I think it isn't surprising that the hardware
it was noticed on has been packed away.

Now I ask the same of others for when I'm (a) well enough to enter
the cold environment in which this machine is currently stored and
(b) can find the time to resurect the machine.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 Serial core
