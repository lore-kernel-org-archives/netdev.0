From: Folkert van Heusden <folkert@vanheusden.com>
Subject: Re: [2.6.15] running tcpdump on 3c905b causes freeze (reproducable)
Date: Sun, 15 Jan 2006 00:36:59 +0100
Message-ID: <20060114233648.GA24049@vanheusden.com>
References: <20060108114305.GA32425@vanheusden.com>
	<20060109041114.6e797a9b.akpm@osdl.org>
	<20060109144522.GB10955@vanheusden.com>
	<20060109193754.GD12673@vanheusden.com>
	<20060109224821.7a40bc69.akpm@osdl.org>
	<20060110142725.GH12673@vanheusden.com>
	<20060114132414.GN6087@vanheusden.com>
	<20060114060457.06efae88.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750829AbWANXhH@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060114060457.06efae88.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >  > > > > > Have you tried enabling the NMI watchdog?  Enable CONFIG_X86_LOCAL_APIC and
> >  > > > > > boot with `nmi_watchdog=1' on the command line, make sure that the NMI line
> >  > > > > > of /proc/interrupts is incrementing.
> >  > > > > I'll give it a try. I've added it to the append-line in the lilo config.
> >  > > > > Am now compiling the kernel.
> >  > > > No change. Well, that is: the last message on the console now is
> >  > > > "setting eth1 to promiscues mode".
> >  > > Did you confirm that the NMI counters in /proc/interrupts are incrementing?
> >  > Yes:
> >  > root@muur:/home/folkert# for i in `seq 1 5` ; do cat /proc/interrupts  | grep NMI ; sleep 1 ; done
> >  > NMI:    6949080    6949067
...
> >  > NMI:    6949488    6949475
> > 
> >  Is there anything else I can try?
> argh.   I haven't forgotten.  Hopefully after -rc1 I'll have more time...

Sorry :-)

> Your report didn't mention whether that card work OK under earlier 2.6
> kernels.  If it does, a bit of bisection searching would really help.

2.6.15   crash
2.6.14.4 crash
2.6.14   crash
2.6.12.6 crash "NMI watchdog detected LOCKUP"
2.6.6    crash "NMI watchdog detected LOCKUP on CPU1 eip c02500aa, registers:"
2.6.1    would not boot


Folkert van Heusden

-- 
Try MultiTail! Multiple windows with logfiles, filtered with regular
expressions, colored output, etc. etc. www.vanheusden.com/multitail/
----------------------------------------------------------------------
Get your PGP/GPG key signed at www.biglumber.com!
----------------------------------------------------------------------
Phone: +31-6-41278122, PGP-key: 1F28D8AE, www.vanheusden.com
