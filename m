From: Madis Janson <madis@ats.cyber.ee>
Subject: Re: forcedeth unknown events 0x21
Date: Tue, 24 Feb 2004 18:04:51 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402241753150.10866@kiku.itsise>
References: <Pine.LNX.4.58.0312180952100.21042@kiku.itsise> <3FE6678B.5070006@gmx.net>
 <Pine.LNX.4.53.0401051456060.1039@alien> <4001D113.3030302@gmx.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2003@gmx.net>
In-Reply-To: <4001D113.3030302@gmx.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Sun, 11 Jan 2004, Carl-Daniel Hailfinger wrote:

> madis wrote:
> > On Mon, 22 Dec 2003, Carl-Daniel Hailfinger wrote:
> >
> >>Madis Janson wrote:
> >>
> >>>When trying forcedeth_2_6_patch_v19.txt, i got the following message
> >>>fastly repeating after ifup eth0:
> >>>
> >>>"eth0: received irq with unknown events 0x21. Please report"
> >>>
> >>>and it didn't work eighter (ifup just stalled).
> [...]
> >>
> >>Please try the attached patch on top of it and report back if it works.
> >
> > the unknown events message disappeared,
> > but the network did not start to work...
>
> Do you use any powermanagement software (athcool, lvcool, fvcool, coolon,
> athlon cooling patch, anything STPGNT related)? Does your BIOS list
> anything STPGNT related?
>

I didn't found anything STPGNT related to be installed or in BIOS.

But seems that the reason for it to not work was actually stupid cable
modem, that remembered other end network cards hardware address and
refused to respond.

That solved, the 2.6.3 kernels forcedeth works, but about half of the
packets are dropped (rtl8139 used for same thing drops almost nothing).
Also it complains now very much about "unknown event 0x1" (instead of
0x21 which was complained when I tried before).
