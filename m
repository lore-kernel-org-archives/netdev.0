From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.13-rc6-mm1: drivers/net/s2io.c: compile error with gcc 4.0
Date: Fri, 19 Aug 2005 17:02:09 +0200
Message-ID: <20050819150209.GD3682@stusta.de>
References: <20050819043331.7bc1f9a9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964952AbVHSPCM@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20050819043331.7bc1f9a9.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 19, 2005 at 04:33:31AM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.13-rc5-mm1:
>...
> -git-netdev-chelsio.patch
> -git-netdev-e100.patch
> -git-netdev-sis190.patch
> -git-netdev-smc91x-eeprom.patch
> -git-netdev-ieee80211-wifi.patch
> -git-netdev-upstream.patch
> +git-netdev-all.patch
> 
>  And a consolidated netdev tree
>...

This patch causes the following compile error with gcc 4.0:

<--  snip  -->

...
  CC      drivers/net/s2io.o
In file included from drivers/net/s2io.c:65:
drivers/net/s2io.h: In function 'readq':
drivers/net/s2io.h:765: error: invalid lvalue in assignment
drivers/net/s2io.h:766: error: invalid lvalue in assignment
drivers/net/s2io.c: In function 'init_shared_mem':
drivers/net/s2io.c:541: warning: cast from pointer to integer of different size
drivers/net/s2io.c:544: warning: cast to pointer from integer of different size
drivers/net/s2io.c:550: warning: cast from pointer to integer of different size
drivers/net/s2io.c:553: warning: cast to pointer from integer of different size
make[2]: *** [drivers/net/s2io.o] Error 1

<--  snip  -->

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
