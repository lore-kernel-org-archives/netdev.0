From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: 2.6.9-mm1: pc_debug multiple definitions
Date: Sat, 23 Oct 2004 00:07:55 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041023000755.E3459@flint.arm.linux.org.uk>
References: <20041022032039.730eb226.akpm@osdl.org> <20041022133929.GA2831@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
        jgarzik@pobox.com, linux-net@vger.kernel.org,
        prism54-private@prism54.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20041022133929.GA2831@stusta.de>; from bunk@stusta.de on Fri, Oct 22, 2004 at 03:39:29PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 22, 2004 at 03:39:29PM +0200, Adrian Bunk wrote:
> 
> The following compile error comes from Linus' tree:
> 
> 
> <--  snip  -->
> 
> ...
>   LD      drivers/built-in.o
> drivers/pcmcia/built-in.o(.bss+0xf20): multiple definition of `pc_debug'
> drivers/net/built-in.o(.data+0x24ae0): first defined here
> make[1]: *** [drivers/built-in.o] Error 1
> 
> <--  snip  -->
> 
> 
> The pc_debug in drivers/pcmcia/ds.c was made non-static in Linus' tree,
> but the global definition of a global variable with such a generic name 
> in drivers/net/wireless/prism54/islpci_mgt.c seems to be equally wrong.

I've forwarded it to Dominik to sort out with suggested solutions.
Hopefully Dominik will forward a fix soon.

(PS, I dropped David Hinds from the CC list - David doesn't maintain
2.6 PCMCIA.)

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
