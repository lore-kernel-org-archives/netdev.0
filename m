From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash, Another Problem)
Date: Thu, 26 Jun 2008 20:35:23 -0600
Message-ID: <20080627023523.GD7703@parisc-linux.org>
References: <4861800B.90703@nscus.com> <20080625213142.GA29890@electric-eye.fr.zoreil.com> <48640535.2050000@nscus.com> <20080626215918.GC2555@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Grollman <mgrollman@nscus.com>, netdev@vger.kernel.org,
	Kasper Sandberg <lkml@metanurb.dk>, akpm@linux-foundation.org,
	linux-pci@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080626215918.GC2555@electric-eye.fr.zoreil.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 26, 2008 at 11:59:18PM +0200, Francois Romieu wrote:
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

Mmm.  All f's means that the device has fallen off the bus.  Nothing is
responding when we ask the device about it's config space.  What do you
do to get this device into this state?

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
