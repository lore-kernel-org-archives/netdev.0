From: Alessandro Zummo <alessandro.zummo@towertech.it>
Subject: Re: [RFC] [PATCH 1/2] Driver to remember ethernet MAC values:
 maclist
Date: Mon, 20 Feb 2006 13:57:18 +0100
Message-ID: <20060220135718.038b675b@inspiron>
References: <20060220010113.GA19309@deprecation.cyrius.com>
	<20060220014735.GD4971@stusta.de>
	<20060220030146.11f418dc@inspiron>
	<43F9B32B.3090203@cantab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, Martin Michlmayr <tbm@cyrius.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	John Bowler <jbowler@acm.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932609AbWBTM5p@vger.kernel.org>
To: David Vrabel <dvrabel@cantab.net>
In-Reply-To: <43F9B32B.3090203@cantab.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Feb 2006 12:16:43 +0000
David Vrabel <dvrabel@cantab.net> wrote:

> >>>Some Ethernet hardware implementations have no built-in storage for
> >>>allocated MAC values - an example is the Intel IXP420 chip which has
> >>>support for Ethernet but no defined way of storing allocated MAC values.
> >>>With such hardware different board level implementations store the
> >>>allocated MAC (or MACs) in different ways.  Rather than put board level
> >>>code
 
> For those not familar with the IXP4xx, the Ethernet drivers are
> proprietary and given that there are no other proposed users of this
> maclist code there's no need for it in the kernel at this time.

> >>Why can't this be implemented in user space using the SIOCSIFHWADDR 
> >>ioctl?
 
> I'm with Adrian on this -- it's a job for userspace.  The storage of the
> MAC address isn't something that's necessarily board specific anyway but
> could depend on which bootloader is used and/or the bootloader version.

> >  Because sometimes you need to have networking available
> >  well before userspace.
> 
> In the specific case of the IXP4xx, you presumably have some userspace
> available because you've just loaded the NPE firmware from it, yes?

 Hi David,
  
  you're certainly right on the ixp4xx, but the are other uses
 for this driver which we are working on.. for example,
 some Cirrus Logic ARM based chips (ep93xx) have an ethernet device
 that could benefit from that.

  I'm pretty sure that there are and will be more devices
 with such requirements, with either proprietary or
 open source drivers. My opinion is that a maclist alike
 facility can clean some of the mess in that area.

  If we implement such a thing in userspace every distribution
 will need to be aware of a specific trick for a specific
 board. If we have a clean facility in the kernel, userspace
 will not need to care.

-- 

 Best regards,

 Alessandro Zummo,
  Tower Technologies - Turin, Italy

  http://www.towertech.it
