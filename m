From: Andi Kleen <ak@suse.de>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Sat, 11 Oct 2003 15:19:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031011131921.GC21763@wotan.suse.de>
References: <3F844578.40306@sgi.com> <20031008101046.376abc3b.davem@redhat.com> <3F8455BE.8080300@sgi.com> <20031008183742.GA24822@wotan.suse.de> <20031008122223.1ba5ac79.davem@redhat.com> <20031008202248.GA15611@oldwotan.suse.de> <3F8702FF.70500@sgi.com> <20031010192036.GA31727@wotan.suse.de> <3F8802E6.5030601@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, "David S. Miller" <davem@redhat.com>,
        johnip@sgi.com, netdev@oss.sgi.com, jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Modica <modica@sgi.com>
Content-Disposition: inline
In-Reply-To: <3F8802E6.5030601@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Oct 11, 2003 at 08:17:26AM -0500, Steve Modica wrote:
> Andi Kleen wrote:
> 
> >>Customers running Suse on Altix have to edit modules.conf anyhow so they 
> >>use the tg3 module (instead of bcm).  So when they do this, we could 
> >>easily have them add an argument to the modules.conf line and we avoid a 
> >>kernel build. This let's us run with a standard ia64 kernel.
> >
> >
> >Doesn't it already have a rx_copy_break argument? If yes just set it to
> >zero and it will always copy. If not add it.
> 
> The problem with this solution is that it also impacts 5704 cards, which 
> don't have the alignment issue. We are figuring all this out.  We may 
> just switch over completely and replace the 5701 cards.

Then just don't set the argument to zero in modules.conf on the 5704cards. 
That could be even handled somewhere in user space.  Switching over sounds 
best of course, because the performance with the copying won't be great

-Andi
