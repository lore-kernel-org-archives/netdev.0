From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/5] r8169: auto detect 32-bit slot
Date: Wed, 9 Mar 2005 15:16:11 -0800
Message-ID: <20050309151611.431accce@dxpl.pdx.osdl.net>
References: <20050309112925.7f7900ab@dxpl.pdx.osdl.net>
	<m17jkgwp6i.fsf@muc.de>
	<20050309214023.GA9502@electric-eye.fr.zoreil.com>
	<20050309135530.5c5c80b6@dxpl.pdx.osdl.net>
	<20050309230809.GC9502@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050309230809.GC9502@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 10 Mar 2005 00:08:09 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Stephen Hemminger <shemminger@osdl.org> :
> [...]
> > I tested on old Celeron with Netgear card.  I could try Amd and/or Xeon
> > if you want.
> 
> If the systems are 64 bit, one would need to know how the driver behaves
> when DAC is forced and:
> 1) the Netgear card is in a 32 bit slot, dma to highmem is enabled and used
> 2) the Netgear card is in a 32 bit slot, dma to highmem is enabled and unused
> 3) the Netgear card is in a 32 bit slot, dma to highmem is disabled
> 4) the Netgear card is in a 64 bit slot, dma to highmem is enabled and used
> 5) the Netgear card is in a 64 bit slot, dma to highmem is enabled and unused
> 6) the Netgear card is in a 64 bit slot, dma to highmem is disabled
> 
> + the content of the Config2 register for 1-6.
> 
> If the amd64 hosts a built-in 8169, add the behavior with highmem disabled or
> enabled + variable amount of memory.
> 
> As it still leaves some archs in the cold + DAC ought not to be dependant
> on the bus width + a few "broken" adapters exist, the patch makes me a bit
> sceptical.

Okay, the motivation was to try and get rid of the module parameter.
I hate to see more parameters, and really don't like it when different drivers
start to do things in different ways.  Don't really have enough background
to know which adapters and arch combinations are broken; so just drop the patch.
