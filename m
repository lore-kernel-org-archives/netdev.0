From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/5] r8169: auto detect 32-bit slot
Date: Thu, 10 Mar 2005 00:08:09 +0100
Message-ID: <20050309230809.GC9502@electric-eye.fr.zoreil.com>
References: <20050309112925.7f7900ab@dxpl.pdx.osdl.net> <m17jkgwp6i.fsf@muc.de> <20050309214023.GA9502@electric-eye.fr.zoreil.com> <20050309135530.5c5c80b6@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@muc.de>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050309135530.5c5c80b6@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
[...]
> I tested on old Celeron with Netgear card.  I could try Amd and/or Xeon
> if you want.

If the systems are 64 bit, one would need to know how the driver behaves
when DAC is forced and:
1) the Netgear card is in a 32 bit slot, dma to highmem is enabled and used
2) the Netgear card is in a 32 bit slot, dma to highmem is enabled and unused
3) the Netgear card is in a 32 bit slot, dma to highmem is disabled
4) the Netgear card is in a 64 bit slot, dma to highmem is enabled and used
5) the Netgear card is in a 64 bit slot, dma to highmem is enabled and unused
6) the Netgear card is in a 64 bit slot, dma to highmem is disabled

+ the content of the Config2 register for 1-6.

If the amd64 hosts a built-in 8169, add the behavior with highmem disabled or
enabled + variable amount of memory.

As it still leaves some archs in the cold + DAC ought not to be dependant
on the bus width + a few "broken" adapters exist, the patch makes me a bit
sceptical.

--
Ueimor
