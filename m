From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] Add 32bit emulation for wireless
Date: Mon, 19 Jan 2004 12:19:12 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119201912.GA9701@bougret.hpl.hp.com>
References: <20040119123343.GA16292@colin2.muc.de> <20040119123945.A32623@infradead.org> <20040119141041.2cccbc3d.ak@suse.de> <20040119055615.4380e157.davem@redhat.com> <20040119153919.14102937.ak@suse.de> <20040119063921.586b37ac.davem@redhat.com> <20040119155412.2bffee5a.ak@suse.de> <20040119194943.GA9360@bougret.hpl.hp.com> <20040119210132.0c52df58.ak@suse.de>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, hch@infradead.org, ak@colin2.muc.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20040119210132.0c52df58.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jan 19, 2004 at 09:01:32PM +0100, Andi Kleen wrote:
> 
> [1] I actually have a Samsung wireless card, but it's not working
> due to missing support for the Cirrus 6729 PCMCIA bridge on there.

	I was wondering, because Samsungs cards should be supported by
the HostAP driver (which remind me, HostAP needs to go in the kernel).

> > 	One of the main strength of OpenSource is that you can
> > recompile for your platform, and I think we should fully exploit this
> > advantage, especially for the base system. Otherwise, why not enable
> > 16bit compatibility on i386 for ELKS packages ?
> 
> I maintain the 32bit emulation on x86-64 and booting an unmodified 32bit distribution
> is an important test case for me. Your suggestion is like someone suggesting 
> to you to just use ethernet with cables instead of this unreliable wireless stuff...

	This analogy doesn't work. If your network is wireless, you
won't connect to it with an Ethernet card (and vice versa). A fully 64
bits userspace has only very minor downside, and most users won't see
any difference. If we follow your line of thought, we should all be
using a 16bit userspace on i386 (more compact, more compatible).

> > 	It seems that the BK->Web stuff has not yet picked your
> > updates, because I don't see them (and of course the snapshot on
> > kernel.org is too old).
> 
> It's actually there, just hidden in a large batch of network updates.

	It was backlogged, it seems to be catching up (but I need to
see if I find it).
http://linux.bkbits.net:8080/linux-2.5/ChangeSet@-4d?nav=index.html

> -Andi

	Jean
