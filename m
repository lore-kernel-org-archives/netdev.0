From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/ipv{4,6}/esp{4,6}.c must #include
 <linux/scatterlist.h>
Date: Fri, 26 Oct 2007 22:54:12 -0700 (PDT)
Message-ID: <20071026.225412.52199506.davem@davemloft.net>
References: <20071027023448.GP30533@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jens.axboe@oracle.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46809
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751795AbXJ0FyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2007 01:54:12 -0400
In-Reply-To: <20071027023448.GP30533@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>
Date: Sat, 27 Oct 2007 04:34:48 +0200

> This patch fixes the following compile errors in some configurations:
> 
> <--  snip  -->
> 
> ...
>   CC      net/ipv4/esp4.o
> /home/bunk/linux/kernel-2.6/git/linux-2.6/net/ipv4/esp4.c: In function 'esp_output':
> /home/bunk/linux/kernel-2.6/git/linux-2.6/net/ipv4/esp4.c:113: error: implicit declaration of function 'sg_init_table'
> make[3]: *** [net/ipv4/esp4.o] Error 1
> ...
> /home/bunk/linux/kernel-2.6/git/linux-2.6/net/ipv6/esp6.c: In function 'esp6_output':
> /home/bunk/linux/kernel-2.6/git/linux-2.6/net/ipv6/esp6.c:112: error: implicit declaration of function 'sg_init_table'
> make[3]: *** [net/ipv6/esp6.o] Error 1
> 
> 
> <--  snip  -->
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Applied, thanks Adrian.
