From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Add 32bit emulation for wireless
Date: Mon, 19 Jan 2004 21:01:32 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119210132.0c52df58.ak@suse.de>
References: <20040119123343.GA16292@colin2.muc.de>
	<20040119123945.A32623@infradead.org>
	<20040119141041.2cccbc3d.ak@suse.de>
	<20040119055615.4380e157.davem@redhat.com>
	<20040119153919.14102937.ak@suse.de>
	<20040119063921.586b37ac.davem@redhat.com>
	<20040119155412.2bffee5a.ak@suse.de>
	<20040119194943.GA9360@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, davem@redhat.com, hch@infradead.org,
        ak@colin2.muc.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040119194943.GA9360@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 19 Jan 2004 11:49:43 -0800
Jean Tourrilhes <jt@bougret.hpl.hp.com> wrote:
> 	However, this is my prefered way to do things. I would much
> prefer to see you using native version of the Wireless Tools,
> especially that the tools and the kernel need to be in sync as far as
> version is concerned. It should be a simple matter of recompiling the
> tools package.

I don't use wireless at all[1] - I was just annoyed at the storm of
unimplemented ioctl messages when booting up 32bit userland.
SuSE 9.0 boot up calls iwconfig by default.

[1] I actually have a Samsung wireless card, but it's not working
due to missing support for the Cirrus 6729 PCMCIA bridge on there.

> 	One of the main strength of OpenSource is that you can
> recompile for your platform, and I think we should fully exploit this
> advantage, especially for the base system. Otherwise, why not enable
> 16bit compatibility on i386 for ELKS packages ?

I maintain the 32bit emulation on x86-64 and booting an unmodified 32bit distribution
is an important test case for me. Your suggestion is like someone suggesting 
to you to just use ethernet with cables instead of this unreliable wireless stuff...

> 
> 	It seems that the BK->Web stuff has not yet picked your
> updates, because I don't see them (and of course the snapshot on
> kernel.org is too old).

It's actually there, just hidden in a large batch of network updates.

-Andi
