From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: /proc/sys/net/ipv[46]/conf/ issue unsolved
Date: Tue, 13 Feb 2007 14:45:38 -0500
Message-ID: <20070213194538.GF25362@hmsreliant.homelinux.net>
References: <200702131529.04708.hasso@estpak.ee> <20070213185820.GB25362@hmsreliant.homelinux.net> <9c46321e0702131124q33b4e263ybc38555cf1544769@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hasso Tepper <hasso@estpak.ee>, netdev@vger.kernel.org
To: Hugo Santos <hugosantos@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3278 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750863AbXBMTqT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 14:46:19 -0500
Content-Disposition: inline
In-Reply-To: <9c46321e0702131124q33b4e263ybc38555cf1544769@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 13, 2007 at 07:24:32PM +0000, Hugo Santos wrote:
> Neil,
> 
> On 2/13/07, Neil Horman <nhorman@tuxdriver.com> wrote:
> >Can't this simply be fixed by adding a custom udev rule?  Correct me if I'm
> >wrong, but the only reason that interfaces come up automatically after 
> >their
> >appropriate module is inserted is because most distos udev rules issue an 
> >ifup
> >$DEVICE when they get a creation event for $DEVICE.  Why not add a custom 
> >rule
> >in for net device creation events to set appropriate sysctl values before 
> >the
> >ifup is issued.
> 
>  The issue is not as much with automatic auto-configuration but with
> not being able to disable auto-configuration (and others) before
> setting the interface up.
> 
Yes, I understand that, but until the IFF_UP flag is set on the interface, it
doesn't really have any effect on the system as a whole.  You should be able to
undo any default setting that you want before you call ifup on the interface, or
am I missing something?

Neil

>  Hugo
