From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH][RFC] Netconsole debugging tool for 2.6
Date: Tue, 12 Aug 2003 13:09:20 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812170920.GB24774@gtf.org>
References: <3F38F5EC.2060003@jburgess.uklinux.net> <20030812163311.GL31810@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jon Burgess <mplayer@jburgess.uklinux.net>,
   linux kernel <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
Content-Disposition: inline
In-Reply-To: <20030812163311.GL31810@waste.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Aug 12, 2003 at 11:33:11AM -0500, Matt Mackall wrote:
> On Tue, Aug 12, 2003 at 03:13:00PM +0100, Jon Burgess wrote:
> > Matt Mackall wrote:
> > > I've decided to take a stab at resurrecting Ingo's netconsole patch.
> > 
> > Is this different from the netdump patch which RedHat include in their 
> > kernel?
> > 
> > The RH kernel patch is at
> > http://www.kernelnewbies.org/kernels/rh9/SOURCES/linux-2.4.18-netdump.patch
> 
> Ahh, so that's what's become of it.
> 
> Theirs:
> - does crashdumps
> - does syslog without levels
> - has hooks for receive
> 
> Mine:
> - works in 2.6
> - has non-appalling configuration
> - works as a built-in and is available earlier in boot
> - does syslog with levels (haven't posted this though)

netconsole does syslog with levels, too.  I agree netdump/netconsole
have complete awful configuration.  I was thinking netlink would be a
good configurator.

The kernel printk <foo> prefixes map into syslog quite nicely.

In any case, there is my own active effort into cleaning up netdump to
be less x86-specific, and get it ready for mainline.

Maybe we can start discussing converging all these implementations on
netdev@oss.sgi.com?  (that's where the networking developers live)

	Jeff
