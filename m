From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3 v2] net/irda: sh_sir: add missing header
Date: Thu, 11 Aug 2011 05:53:57 -0700 (PDT)
Message-ID: <20110811.055357.1702109063499880852.davem@davemloft.net>
References: <20110810.231558.2202030270747790994.davem@davemloft.net>
	<877h6kwbiq.wl%kuninori.morimoto.gx@renesas.com>
	<874o1owb82.wl%kuninori.morimoto.gx@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuninori.morimoto.gx@renesas.com, netdev@vger.kernel.org
To: kuninori.morimoto.gx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36459 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755827Ab1HKMyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 08:54:02 -0400
In-Reply-To: <874o1owb82.wl%kuninori.morimoto.gx@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kuninori.morimoto.gx@gmail.com
Date: Thu, 11 Aug 2011 02:26:09 -0700 (PDT)

> From: Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
> 
> This patch fixup below build error on sh_sir
> 
> sh_sir.c: In function 'sh_sir_write':
> sh_sir.c:127:2: error: implicit declaration of function 'iowrite16'
> sh_sir.c: In function 'sh_sir_read':
> sh_sir.c:132:2: error: implicit declaration of function 'ioread16'
> sh_sir.c: At top level:
> sh_sir.c:561:20: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'sh_sir_irq'
> sh_sir.c: In function 'sh_sir_probe':
> sh_sir.c:727:2: error: implicit declaration of function 'ioremap_nocache'
> sh_sir.c:727:16: warning: assignment makes pointer from integer without a cast
> sh_sir.c:762:2: error: implicit declaration of function 'request_irq'
> sh_sir.c:762:23: error: 'sh_sir_irq' undeclared (first use in this function)
> sh_sir.c:762:23: note: each undeclared identifier is reported only once for each function it appears in
> sh_sir.c:762:35: error: 'IRQF_DISABLED' undeclared (first use in this function)
> sh_sir.c:776:2: error: implicit declaration of function 'iounmap'
> sh_sir.c: At top level:
> sh_sir.c:436:13: warning: 'sh_sir_clear_all_err' defined but not used
> sh_sir.c:474:12: warning: 'sh_sir_is_which_phase' defined but not used
> sh_sir.c:490:13: warning: 'sh_sir_tx' defined but not used
> sh_sir.c:540:13: warning: 'sh_sir_rx' defined but not used
> 
> Signed-off-by: Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>

Applied.
