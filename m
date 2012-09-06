From: Jason Baron <jbaron@redhat.com>
Subject: Re: [PATCH 0/5] dev_<level> and dynamic_debug cleanups
Date: Thu, 6 Sep 2012 13:53:13 -0400
Message-ID: <20120906175313.GC9786@redhat.com>
References: <cover.1345978012.git.joe@perches.com>
 <CAJfuBxyQc-XeNHxw0_XDs0JuCrNArNzcgsmrLya4ncDvSojZxQ@mail.gmail.com>
 <CAJfuBxyToA9-=c3H88GGba3GFX64kdbP4OCEC0f4trnBnjpU-w@mail.gmail.com>
 <20120906161359.GC23641@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jim Cromie <jim.cromie@gmail.com>, Kay Sievers <kay@vrfy.org>,
	Joe Perches <joe@perches.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120906161359.GC23641@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 06, 2012 at 09:13:59AM -0700, Greg Kroah-Hartman wrote:
> On Thu, Aug 30, 2012 at 09:48:12PM -0600, Jim Cromie wrote:
> > On Thu, Aug 30, 2012 at 11:43 AM, Jim Cromie <jim.cromie@gmail.com> wrote:
> > > On Sun, Aug 26, 2012 at 5:25 AM, Joe Perches <joe@perches.com> wrote:
> > >> The recent commit to fix dynamic_debug was a bit unclean.
> > >> Neaten the style for dynamic_debug.
> > >> Reduce the stack use of message logging that uses netdev_printk
> > >> Add utility functions dev_printk_emit and dev_vprintk_emit for /dev/kmsg.
> > >>
> > >> Joe Perches (5):
> > >>   dev_dbg/dynamic_debug: Update to use printk_emit, optimize stack
> > >>   netdev_printk/dynamic_netdev_dbg: Directly call printk_emit
> > >>   netdev_printk/netif_printk: Remove a superfluous logging colon
> > >>   dev: Add dev_vprintk_emit and dev_printk_emit
> > >>   device and dynamic_debug: Use dev_vprintk_emit and dev_printk_emit
> > >>
> > >
> > > Ive tested this on 2 builds differing only by DYNAMIC_DEBUG
> > > It works for me on x86-64
> > >
> > > However, I just booted a non-dyndbg build on x86-32, and got this.
> > >
> > 
> > Ok, transient error, went away with a clean build.
> > 
> > tested-by: Jim Cromie <jim.cromie@gmail.com>
> 
> Jason, any ACK on these, or any of the other random dynamic debug
> patches floating around?  What am I supposed to be applying here?
> 

Hi Greg,

I just posted some follow up comments to Joe, so let's see where that
discussion goes.

Thanks,

-Jason 
