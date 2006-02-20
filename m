From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [RFC] [PATCH 1/2] Driver to remember ethernet MAC values: maclist
Date: Mon, 20 Feb 2006 03:39:00 +0100
Message-ID: <20060220023900.GE4971@stusta.de>
References: <20060220010113.GA19309@deprecation.cyrius.com> <20060220014735.GD4971@stusta.de> <20060220030146.11f418dc@inspiron>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Michlmayr <tbm@cyrius.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, John Bowler <jbowler@acm.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932425AbWBTCjE@vger.kernel.org>
To: Alessandro Zummo <alessandro.zummo@towertech.it>
Content-Disposition: inline
In-Reply-To: <20060220030146.11f418dc@inspiron>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 20, 2006 at 03:01:46AM +0100, Alessandro Zummo wrote:
> On Mon, 20 Feb 2006 02:47:35 +0100
> Adrian Bunk <bunk@stusta.de> wrote:
> 
> > > Some Ethernet hardware implementations have no built-in storage for
> > > allocated MAC values - an example is the Intel IXP420 chip which has
> > > support for Ethernet but no defined way of storing allocated MAC values.
> > > With such hardware different board level implementations store the
> > > allocated MAC (or MACs) in different ways.  Rather than put board level
> > > c
> > Silly question:
> > 
> > Why can't this be implemented in user space using the SIOCSIFHWADDR 
> > ioctl?
> 
>  Because sometimes you need to have networking available
>  well before userspace.
> 
>  (netconsole, root over nfs, ...)

Why can't setting MAC addresses be done from initramfs?

>  Best regards,
>  Alessandro Zummo,

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
