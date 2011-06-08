From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Wed, 08 Jun 2011 00:16:12 -0700 (PDT)
Message-ID: <20110608.001612.225121497206099693.davem@davemloft.net>
References: <20110608155411.c3a2aa09.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, adobriyan@gmail.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110608155411.c3a2aa09.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 8 Jun 2011 15:54:11 +1000

> After merging the final tree, today's linux-next build (powerpc
> allyesconfig) failed like this:
> 
> drivers/net/ll_temac_main.c: In function 'temac_open':
> drivers/net/ll_temac_main.c:859:2: error: implicit declaration of function 'request_irq'
> drivers/net/ll_temac_main.c:870:2: error: implicit declaration of function 'free_irq'
> drivers/net/ll_temac_main.c: In function 'temac_poll_controller':
> drivers/net/ll_temac_main.c:903:2: error: implicit declaration of function 'disable_irq'
> drivers/net/ll_temac_main.c:909:2: error: implicit declaration of function 'enable_irq'

Oh well, I hit all the drivers I could with x86 and sparc64 builds.

> Probably caused by commit a6b7a407865a ("net: remove interrupt.h
> inclusion from netdevice.h").
> 
> I have added this patch for today:
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Wed, 8 Jun 2011 15:49:33 +1000
> Subject: [PATCH] net: add needed interrupt.h

Applied, thanks Stephen.
