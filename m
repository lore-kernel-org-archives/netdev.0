From: madis <madis@cyber.ee>
Subject: Re: forcedeth unknown events 0x21
Date: Mon, 5 Jan 2004 14:58:48 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.53.0401051456060.1039@alien>
References: <Pine.LNX.4.58.0312180952100.21042@kiku.itsise> <3FE6678B.5070006@gmx.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Madis Janson <madis@ats.cyber.ee>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2003@gmx.net>
In-Reply-To: <3FE6678B.5070006@gmx.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Mon, 22 Dec 2003, Carl-Daniel Hailfinger wrote:

> Madis Janson wrote:
> > When trying forcedeth_2_6_patch_v19.txt, i got the following message
> > fastly repeating after ifup eth0:
> >
> > "eth0: received irq with unknown events 0x21. Please report"
> >
> > and it didn't work eighter (ifup just stalled).
> >
> > kernel:
> >
> > 2.6.0 release + patches:
> > http://www.held.org.il/patches/patch-lirc-2.6.0-test9-oh.diff.bz2
> > http://www.hailfinger.org/carldani/linux/patches/forcedeth/forcedeth_2_6_patch_v19.txt
>
> Please try the attached patch on top of it and report back if it works.
>

the unknown events message disappeared,
but the network did not start to work...

========================================================
+               if (events & (NVREG_IRQ_RX_ERR)) {
+                       dprintk(KERN_DEBUG "%s: received irq with events
0x%x.
Probably RX fail.\n",
+                                               dev->name, events);
here were '}' missing.

-- 
mzz
