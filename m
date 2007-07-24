From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 2/3] netdev: i82596 Ethernet needs <asm/cacheflush.h>
Date: Tue, 24 Jul 2007 16:37:55 -0400
Message-ID: <46A66323.7000000@garzik.org>
References: <20070720164043.523003359@mail.of.borg> <20070720164323.848002388@mail.of.borg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59045 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932334AbXGXUh7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 16:37:59 -0400
In-Reply-To: <20070720164323.848002388@mail.of.borg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Geert Uytterhoeven wrote:
> netdev: i82596 Ethernet needs <asm/cacheflush.h> on m68k
> 
> drivers/net/82596.c: In function 'init_rx_bufs':
> drivers/net/82596.c:552: error: implicit declaration of function 'cache_clear'
> drivers/net/82596.c: In function 'i596_start_xmit':
> drivers/net/82596.c:1104: error: implicit declaration of function 'cache_push'
> 
> The driver still compiles on ia32 (CONFIG_APRICOT=y)
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

applied


