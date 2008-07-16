From: Adrian Bunk <bunk@kernel.org>
Subject: Re: Compilation error on drivers/md/raid6int8.c on net-next-2.6
Date: Wed, 16 Jul 2008 21:31:28 +0300
Message-ID: <20080716183128.GG17329@cs181140183.pp.htv.fi>
References: <487E364C.3050200@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <487E364C.3050200@linux.vnet.ibm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 16, 2008 at 02:56:28PM -0300, Breno Leitao wrote:
> I just pulled net-next-2.6 and compiling it on a ppc machine I got the  
> following error:
>
>
>  CC [M]  drivers/md/raid6tables.o
>  CC [M]  drivers/md/raid6int8.o
> drivers/md/raid6int8.c: In function `raid6_int8_gen_syndrome':
> drivers/md/raid6int8.c:185: error: unable to find a register to spill in  
> class `FLOAT_REGS'
> drivers/md/raid6int8.c:185: error: this is the insn:
> (insn:HI 619 799 638 4 drivers/md/raid6int8.c:168 (set (mem:DI (plus:DI  
> (reg/v/f:DI 122 [ p ])
>                (reg/v:DI 66 ctr [orig:124 d ] [124])) [0 S8 A64])
>        (reg/v:DI 129 [ wp0 ])) 320 {*movdi_internal64} (nil)
>    (expr_list:REG_DEAD (reg/v:DI 129 [ wp0 ])
>        (nil)))
> drivers/md/raid6int8.c:185: confused by earlier errors, bailing out
> make[2]: *** [drivers/md/raid6int8.o] Error 1
> make[1]: *** [drivers/md] Error 2
> make: *** [drivers] Error 2

That's a gcc bug.

Which gcc version are you using?

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
