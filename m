From: Jurriaan <thunder7@xs4all.nl>
Subject: Re: strange network performance degradation 2.6.8-rc3-mm1 -> 2.6.8-rc4-mm1
Date: Sat, 14 Aug 2004 21:01:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040814190140.GA1954@middle.of.nowhere>
References: <20040814060948.GA7842@middle.of.nowhere> <20040814121533.GB18754@electric-eye.fr.zoreil.com> <20040814135606.GA6001@middle.of.nowhere> <20040814150824.GA21843@electric-eye.fr.zoreil.com> <20040814161039.GA1985@middle.of.nowhere> <20040814172835.GA23427@electric-eye.fr.zoreil.com>
Reply-To: Jurriaan <thunder7@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20040814172835.GA23427@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, Aug 14, 2004 at 07:28:35PM +0200
> Jurriaan <thunder7@xs4all.nl> :
> [...]
> > Never mind, it seems my patch was saved incorrectly. Anyway, after
> > applying this patch my network-traffic is as fast as it ever was.
> > 
> > There's no difference in dmesg-output, but I reach 450-460 KiB/s again.
> 
> Ok. So Jeff was right (TM).
> 
> > If there's anything else I can test, please let me know - I gather the
> > update did work for other people, so if testers are wanted I'm
> > available.
> 
> Can you apply 8139too-10.patch + 8139too-20.patch on top of your working
> config (namely 2.6.8-rc4-mm1 + 8139too-mm-revert.patch) and tell if things
> go wrong ?
> 
Indeed they do. Both with -10 and with -10+-20 added on my working
2.6.8-rc4-mm1 the booting process hangs somewhere while iptables is
installing my ipv6 firewall. This is reproducable, I've not tried to
install my firewall by hand after booting (call me paranoid).

Thus:

2.6.8-rc4-mm1: boots, slow network
2.6.8-rc4-mm1 + 8139too-mm-revert: boots, fast network
2.6.8-rc4-mm1 + 8139too-mm-revert + 8139too-10: doesn't boot
2.6.8-rc4-mm1 + 8139too-mm-revert + 8139too-10 + 8139too-20: doesn't boot

Good luck,
Jurriaan
-- 
Linux hackers are funny people: They count the time in patchlevels.
	Gerd Knorr
Debian (Unstable) GNU/Linux 2.6.8-rc4-mm1 2x6078 bogomips load 0.01
