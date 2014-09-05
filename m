From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/fddi/skfp/h/skfbi.h: Remove useless
 PCI_BASE_2ND macros
Date: Fri, 05 Sep 2014 14:52:10 -0700 (PDT)
Message-ID: <20140905.145210.1213133106797408601.davem@davemloft.net>
References: <54073322.6030508@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	michal.simek@xilinx.com, monstr@monstr.eu
To: gang.chen.5i5j@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54073322.6030508@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chen Gang <gang.chen.5i5j@gmail.com>
Date: Wed, 03 Sep 2014 23:26:26 +0800

> They are use less, and may generate compiling warnings, so remove them
> (microblaze, arc, arm64, and unicore32 have already defined PCI_IOBASE).
> 
> The related warnings (with allmodconfig under microblaze):
> 
>   CC [M]  drivers/net/fddi/skfp/skfddi.o
>   In file included from drivers/net/fddi/skfp/skfddi.c:95:0:
>   drivers/net/fddi/skfp/h/skfbi.h:151:0: warning: "PCI_IOBASE" redefined
>    #define PCI_IOBASE 0xffffff00L  /* Bit 31..8:  I/O Base address */
>    ^
>   In file included from include/linux/io.h:22:0,
>                    from include/linux/pci.h:31,
>                    from drivers/net/fddi/skfp/skfddi.c:82:
>   ./arch/microblaze/include/asm/io.h:33:0: note: this is the location of the previous definition
>    #define PCI_IOBASE ((void __iomem *)_IO_BASE)
>    ^
> 
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>

Applied, thanks.
