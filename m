From: Kasper Sandberg <lkml@metanurb.dk>
Subject: Re: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in
	Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash, Another
	Problem)
Date: Mon, 07 Jul 2008 14:53:56 +0200
Message-ID: <1215435236.11909.121.camel@localhost>
References: <4861800B.90703@nscus.com>
	 <20080625213142.GA29890@electric-eye.fr.zoreil.com>
	 <48640535.2050000@nscus.com>
	 <20080626215918.GC2555@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Grollman <mgrollman@nscus.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-pci@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20080626215918.GC2555@electric-eye.fr.zoreil.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-06-26 at 23:59 +0200, Francois Romieu wrote:
> (linux-pci Cced)
> 
> Michael Grollman <mgrollman@nscus.com> :
> [...]
> > Per instructions, I built an 2.6.26-rc8 system on the target Intel 
> > hardware, and was able to re-recreate the intermittent failure of the 8201. 
> >  When in failure mode, the lspci -vx' display of the pci registers of the 
> > 8102 is as follows:
> >
> > 01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8101E PCI 
> > Express Fast Ethernet controller (rev ff) (prog-if ff)
> >    !!! Unknown header type 7f
> > 00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> > 10: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> > 20: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> > 30: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> 
> Bad mojo.
> 
> Can you reproduce the failure of the driver or lspci when you
> boot the kernel with "pci=nommconf" (assuming CONFIG_PCI_MMCONFIG is
> set in your .config) or "pci=conf1" (if CONFIG_PCI_DIRECT is instead).
> 
> [...]
> > Let me know if there is anything else I can do to collect information on 
> > this situation.
> 
> The (gzipped) content of your .config.
> 
> Kasper, could you check if you have the same symptoms with
> 2.6.26-rc8 (once your rendering is finished of course) ?
> 
Sorry for the delay, i had to do an onsite thing in another country, so
i first see your message now.

Would it be okay if i took rc9 instead? also, i saw you posted a set of
patches to sync more with realteks code, is this something you would
like me to test too, or aswell? (remember, i have the 8111c).

Btw, a thought just crossed my mind as to a possible reason why this
might be happening, i was googling around, and it seems the TWO nic's
are supposed to have some sort of hardware bonding thing, could it be
because such stuff isnt handled?

mvh.
Kasper Sandberg
