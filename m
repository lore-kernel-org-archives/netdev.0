From: Ralph Doncaster <ralph@istop.com>
Subject: Re: [Bonding-devel] Re: [RFC][bonding] Improve VLAN support on top
 of bonding
Date: Wed, 16 Jul 2003 08:33:04 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.51.0307160825380.24629@ns.istop.com>
References: <Pine.LNX.4.44.0307151115500.6012-100000@sasami.anime.net>
 <Pine.LNX.4.51.0307151434100.4590@ns.istop.com> <3F14807E.30402@pobox.com>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dan Hollis <goemon@anime.net>, linux-netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F14807E.30402@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Jul 2003, Jeff Garzik wrote:

> Ralph Doncaster wrote:
> > On Tue, 15 Jul 2003, Dan Hollis wrote:
> >
> >
> >>That is exactly what it does. hw tcp checksumming helps a LOT at gbe rates
> >
> >
> > This still doesn't make any sense.  The copy from user-space to kernel
> > space does the checksum as far as I recall (unless you use the
> > router-not-host kernel build option).
>
>
> Not for the zero-copy case.

How common is this?  As far as I can tell, Apache 1.3 doesn't use sendfile
(you need 2.0 for that).  And even if 1.3 is using EnableMMAP with a large
write, you're limited to the size of SO_SNDBUF (or maybe only a single
page?).

This is not to say hw csum is a bad thing.  I think the linux IP stack
should support it.  When I was looking at the 2.4.19 code I noticed the
3c59x driver code supported hw csum, but I couldn't find anything in the
IP stack that used the csum flags set by the driver...

-Ralph
