From: Jurriaan <thunder7@xs4all.nl>
Subject: Re: strange network performance degradation 2.6.8-rc3-mm1 -> 2.6.8-rc4-mm1
Date: Sun, 15 Aug 2004 07:54:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040815055455.GA1496@middle.of.nowhere>
References: <20040814060948.GA7842@middle.of.nowhere> <20040814121533.GB18754@electric-eye.fr.zoreil.com> <20040814135606.GA6001@middle.of.nowhere> <20040814150824.GA21843@electric-eye.fr.zoreil.com> <20040814161039.GA1985@middle.of.nowhere> <20040814172835.GA23427@electric-eye.fr.zoreil.com> <20040814190140.GA1954@middle.of.nowhere> <20040814192740.GB23427@electric-eye.fr.zoreil.com>
Reply-To: Jurriaan <thunder7@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20040814192740.GB23427@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, Aug 14, 2004 at 09:27:40PM +0200
> Jurriaan <thunder7@xs4all.nl> :
> [...]
> > Indeed they do. Both with -10 and with -10+-20 added on my working
> > 2.6.8-rc4-mm1 the booting process hangs somewhere while iptables is
> > installing my ipv6 firewall. This is reproducable, I've not tried to
> > install my firewall by hand after booting (call me paranoid).
> > 
> > Thus:
> > 
> > 2.6.8-rc4-mm1: boots, slow network
> > 2.6.8-rc4-mm1 + 8139too-mm-revert: boots, fast network
> > 2.6.8-rc4-mm1 + 8139too-mm-revert + 8139too-10: doesn't boot
> > 2.6.8-rc4-mm1 + 8139too-mm-revert + 8139too-10 + 8139too-20: doesn't boot
> 
> Thanks. Erm... not exactly what I had expected.
> 
> Could you return to 2.6.8-rc4-mm1 + 8139too-mm-revert.patch and try each
> of the three patches attached ?
> 
patch #1 boots
patch #2 doesn't boot
patch #3 boots

btw, if I shut off my ipv6 firewall, patch #2 hangs in the ntpupdate
script, so it looks like the network card is hanging the system on first
actual use with #2.

Kind regards,
Jurriaan
-- 
Well, let's just say, 'if your VCR is still blinking 12:00,
you don't want Linux'.
	Bruce Perens, Debian's Fearless Leader
Debian (Unstable) GNU/Linux 2.6.8-rc4-mm1 2x6078 bogomips load 0.34
