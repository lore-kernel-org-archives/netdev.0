From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Add 32bit emulation for wireless
Date: Mon, 19 Jan 2004 21:35:01 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119213501.4d2420e8.ak@suse.de>
References: <20040119123343.GA16292@colin2.muc.de>
	<20040119123945.A32623@infradead.org>
	<20040119141041.2cccbc3d.ak@suse.de>
	<20040119055615.4380e157.davem@redhat.com>
	<20040119153919.14102937.ak@suse.de>
	<20040119063921.586b37ac.davem@redhat.com>
	<20040119155412.2bffee5a.ak@suse.de>
	<20040119194943.GA9360@bougret.hpl.hp.com>
	<20040119210132.0c52df58.ak@suse.de>
	<20040119201912.GA9701@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, davem@redhat.com, hch@infradead.org,
        ak@colin2.muc.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040119201912.GA9701@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 19 Jan 2004 12:19:12 -0800
Jean Tourrilhes <jt@bougret.hpl.hp.com> wrote:

> On Mon, Jan 19, 2004 at 09:01:32PM +0100, Andi Kleen wrote:
> > 
> > [1] I actually have a Samsung wireless card, but it's not working
> > due to missing support for the Cirrus 6729 PCMCIA bridge on there.
> 
> 	I was wondering, because Samsungs cards should be supported by
> the HostAP driver (which remind me, HostAP needs to go in the kernel).

It apparently works with David Hinds' PCMCIA kit, but that is far
too messy to patch into a changing development kernel all the time.
The main problem seems to be the missing bridge support in the kernel
PCMCIA, so the wireless driver cannot even see the chip.

> > > 	One of the main strength of OpenSource is that you can
> > > recompile for your platform, and I think we should fully exploit this
> > > advantage, especially for the base system. Otherwise, why not enable
> > > 16bit compatibility on i386 for ELKS packages ?
> > 
> > I maintain the 32bit emulation on x86-64 and booting an unmodified 32bit distribution
> > is an important test case for me. Your suggestion is like someone suggesting 
> > to you to just use ethernet with cables instead of this unreliable wireless stuff...
> 
> 	This analogy doesn't work. If your network is wireless, you
> won't connect to it with an Ethernet card (and vice versa). A fully 64
> bits userspace has only very minor downside, and most users won't see
> any difference. If we follow your line of thought, we should all be
> using a 16bit userspace on i386 (more compact, more compatible).

My point was not that I think it's so great to run 32bit user space. In fact on AMD64 
the 64bit compiler generates in general better and often more compact code than the 
32bit compiler. Most of my 64bit machines are running with full 64bit userland.
But it's very useful to have working 32bit emulation for many reasons, 
and going from good application emulation to supporting a full distribution boot 
is only  a small step and a great test.

-Andi
