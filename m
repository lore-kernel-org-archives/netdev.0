From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3 v2] net/irda: sh_irda: add missing header
Date: Thu, 11 Aug 2011 05:53:51 -0700 (PDT)
Message-ID: <20110811.055351.392548310063665446.davem@davemloft.net>
References: <20110810.231558.2202030270747790994.davem@davemloft.net>
	<877h6kwbiq.wl%kuninori.morimoto.gx@renesas.com>
	<8762m4wb8t.wl%kuninori.morimoto.gx@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuninori.morimoto.gx@renesas.com, netdev@vger.kernel.org
To: kuninori.morimoto.gx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36451 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755825Ab1HKMx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 08:53:57 -0400
In-Reply-To: <8762m4wb8t.wl%kuninori.morimoto.gx@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kuninori.morimoto.gx@gmail.com
Date: Thu, 11 Aug 2011 02:25:42 -0700 (PDT)

> From: Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
> 
> This patch fixup below build error on sh_irda
> 
> sh_irda.c: In function 'sh_irda_write':
> sh_irda.c:174: error: implicit declaration of function 'iowrite16'
> sh_irda.c: In function 'sh_irda_read':
> sh_irda.c:184: error: implicit declaration of function 'ioread16'
> sh_irda.c: At top level:
> sh_irda.c:492: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'sh_irda_irq'
> sh_irda.c: In function 'sh_irda_probe':
> sh_irda.c:776: error: implicit declaration of function 'ioremap_nocache'
> sh_irda.c:776: warning: assignment makes pointer from integer without a cast
> sh_irda.c:811: error: implicit declaration of function 'request_irq'
> sh_irda.c:811: error: 'sh_irda_irq' undeclared (first use in this function)
> sh_irda.c:811: error: (Each undeclared identifier is reported only once
> sh_irda.c:811: error: for each function it appears in.)
> sh_irda.c:811: error: 'IRQF_DISABLED' undeclared (first use in this function)
> sh_irda.c:825: error: implicit declaration of function 'iounmap'
> 
> Signed-off-by: Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>

Applied.
