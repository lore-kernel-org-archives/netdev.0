From: Jurriaan <thunder7@xs4all.nl>
Subject: Re: strange network performance degradation 2.6.8-rc3-mm1 -> 2.6.8-rc4-mm1
Date: Sat, 14 Aug 2004 18:10:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040814161039.GA1985@middle.of.nowhere>
References: <20040814060948.GA7842@middle.of.nowhere> <20040814121533.GB18754@electric-eye.fr.zoreil.com> <20040814135606.GA6001@middle.of.nowhere> <20040814150824.GA21843@electric-eye.fr.zoreil.com>
Reply-To: Jurriaan <thunder7@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20040814150824.GA21843@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, Aug 14, 2004 at 05:08:24PM +0200
> Jurriaan <thunder7@xs4all.nl> :
> [...]
> > > 1 - try the "pci=routeirq" argument at startup on your 2.6.8-rc4-mm1 if you
> > >     have not done so;
> > 
> > that didn't help
> 
> Ok. Bad day.
> 
> [...]
> > > 2 - apply to your 2.6.8-rc4-mm1 tree:
> > >     http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.8-rc4-mm1/8139too-mm-revert.patch
> > 
> > I don't get it.
> [...]
> > This patch fails both with and without -R - how am I supposed to apply
> > it?
> 
Never mind, it seems my patch was saved incorrectly. Anyway, after
applying this patch my network-traffic is as fast as it ever was.

There's no difference in dmesg-output, but I reach 450-460 KiB/s again.

If there's anything else I can test, please let me know - I gather the
update did work for other people, so if testers are wanted I'm
available.

Kind regards,
Jurriaan
-- 
'Tempers grow short,' Kruppe murmured as the commander rode away. 'But not
as short as Kruppe, for whom all nasty words whiz impactless over his head,
and are thus lost in the ether. And those darts aimed lower, ah, they but
bounce from Kruppe's ample equanimity--'
	Steven Erikson - Memories of Ice
Debian (Unstable) GNU/Linux 2.6.8-rc4-mm1 2x6078 bogomips load 0.20
