From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] Add 32bit emulation for wireless
Date: Mon, 19 Jan 2004 12:51:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119205100.GB10116@bougret.hpl.hp.com>
References: <20040119123945.A32623@infradead.org> <20040119141041.2cccbc3d.ak@suse.de> <20040119055615.4380e157.davem@redhat.com> <20040119153919.14102937.ak@suse.de> <20040119063921.586b37ac.davem@redhat.com> <20040119155412.2bffee5a.ak@suse.de> <20040119194943.GA9360@bougret.hpl.hp.com> <20040119210132.0c52df58.ak@suse.de> <20040119201912.GA9701@bougret.hpl.hp.com> <20040119213501.4d2420e8.ak@suse.de>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, hch@infradead.org, ak@colin2.muc.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20040119213501.4d2420e8.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jan 19, 2004 at 09:35:01PM +0100, Andi Kleen wrote:
> On Mon, 19 Jan 2004 12:19:12 -0800
> Jean Tourrilhes <jt@bougret.hpl.hp.com> wrote:
> 
> > On Mon, Jan 19, 2004 at 09:01:32PM +0100, Andi Kleen wrote:
> > > 
> > > [1] I actually have a Samsung wireless card, but it's not working
> > > due to missing support for the Cirrus 6729 PCMCIA bridge on there.
> > 
> > 	I was wondering, because Samsungs cards should be supported by
> > the HostAP driver (which remind me, HostAP needs to go in the kernel).
> 
> It apparently works with David Hinds' PCMCIA kit, but that is far
> too messy to patch into a changing development kernel all the time.
> The main problem seems to be the missing bridge support in the kernel
> PCMCIA, so the wireless driver cannot even see the chip.

	I see you have it covered :
http://www.ussg.iu.edu/hypermail/linux/kernel/0312.1/0469.html
	You may want to get in touch with Dominik Brodowski and
Russell King, because the i82365 driver in 2.6.X is fairly stable (as
opposed to the CardBus stuff).

> -Andi

	Jean
