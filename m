From: Srihari Vijayaraghavan <harisri@bigpond.com>
Subject: Re: [patch] 2.6.5-rc2 - r8169 DAC
Date: Sat, 3 Apr 2004 12:08:16 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404031208.17066.harisri@bigpond.com>
References: <20040329193604.A4744@electric-eye.fr.zoreil.com> <20040329223513.C4744@electric-eye.fr.zoreil.com> <20040403010045.A12904@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, Andi Kleen <ak@suse.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040403010045.A12904@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Francois,

On Saturday 03 April 2004 09:00, Francois Romieu wrote:
> By popular request, patch for DAC on r8169 is available at:
> http://www.fr.zoreil.com/people/francois/misc/20040403-2.6.5-rc2-r8169.c-te
>st.patch
>
> It applies against 2.6.5-rc2 (i.e. anything 2.6.5-rcX I guess).
Yes it does apply cleanly on both 2.6.5-rc2 and 2.6.5-rc3.

> A tester on a x86-32 and a tester on something-64 bits would be _really_
> welcome.

I can test your patch on x86-64, but it does not compile. Here is the error 
message (same error message on both 2.6.5-rc2 and 2.6.5-rc3):
  CC [M]  drivers/net/r8169.o
drivers/net/r8169.c: In function `rtl8169_init_board':
drivers/net/r8169.c:730: error: `DMA_64BIT_MASK' undeclared (first use in this 
function)
drivers/net/r8169.c:730: error: (Each undeclared identifier is reported only 
once
drivers/net/r8169.c:730: error: for each function it appears in.)
drivers/net/r8169.c:733: error: `DMA_32BIT_MASK' undeclared (first use in this 
function)
drivers/net/r8169.c: In function `rtl8169_hw_start':
drivers/net/r8169.c:1138: error: `DMA_32BIT_MASK' undeclared (first use in 
this function)
make[2]: *** [drivers/net/r8169.o] Error 1
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2
  CC      net/core/dev.o
make: *** Waiting for unfinished jobs....

Thanks
Hari
