From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [git patches] 2.6.x net driver updates
Date: Fri, 13 Jan 2006 00:14:12 +0100
Message-ID: <20060112231412.GB29663@stusta.de>
References: <20060112221322.GA25470@havoc.gtf.org> <Pine.LNX.4.64.0601121423120.3535@g5.osdl.org> <20060112224227.GA26888@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161454AbWALXOO@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20060112224227.GA26888@havoc.gtf.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 12, 2006 at 05:42:27PM -0500, Jeff Garzik wrote:
> On Thu, Jan 12, 2006 at 02:30:19PM -0800, Linus Torvalds wrote:
> > 
> > 
> > On Thu, 12 Jan 2006, Jeff Garzik wrote:
> > > 
> > > dann frazier:
> > >       CONFIG_AIRO needs CONFIG_CRYPTO
> > 
> > I think this is done wrong.
> > 
> > It should "select CRYPTO" rather than "depends on CRYPTO".
> 
> OK
>...

What was wrong with my patch [1] that did not only this, but also fixes 
the same bug with AIRO_CS and removes all the #ifdef's for the 
non-compiling CRYPTO=n case from the driver?

> 	Jeff

cu
Adrian

[1] http://lkml.org/lkml/2006/1/10/328

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
