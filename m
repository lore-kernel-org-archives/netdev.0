From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [RFC] [PATCH 1/2] Driver to remember ethernet MAC values: maclist
Date: Mon, 20 Feb 2006 02:47:35 +0100
Message-ID: <20060220014735.GD4971@stusta.de>
References: <20060220010113.GA19309@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	John Bowler <jbowler@acm.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932521AbWBTBrj@vger.kernel.org>
To: Martin Michlmayr <tbm@cyrius.com>
Content-Disposition: inline
In-Reply-To: <20060220010113.GA19309@deprecation.cyrius.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 20, 2006 at 01:01:13AM +0000, Martin Michlmayr wrote:

> From: John Bowler <jbowler@acm.org>
> 
> Some Ethernet hardware implementations have no built-in storage for
> allocated MAC values - an example is the Intel IXP420 chip which has
> support for Ethernet but no defined way of storing allocated MAC values.
> With such hardware different board level implementations store the
> allocated MAC (or MACs) in different ways.  Rather than put board level
> code into a specific Ethernet driver this driver provides a generally
> accessible repository for the MACs which can be written by board level
> code and read by the driver.
> 
> The implementation also allows user level programs to access the MAC
> information in /proc/net/maclist.  This is useful as it allows user space
> code to use the MAC if it is not used by a built-in driver.
> 
> This driver has been used for several months on various IXP420 based
> platforms within the NSLU2-Linux project, including the Linksys NSLU2.
> A sample implementation of the use of maclist is sent as patch 2.  This
> one is for the Linksys NSLU2, but several more patches for other IXP420
> based platforms are available.
>...

Silly question:

Why can't this be implemented in user space using the SIOCSIFHWADDR 
ioctl?

> Martin Michlmayr

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
