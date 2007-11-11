From: Adrian Bunk <bunk@kernel.org>
Subject: drivers/net/ax88796.c compile error on sh64
Date: Sun, 11 Nov 2007 10:06:21 +0100
Message-ID: <20071111090620.GK21669@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org,
	linuxsh-shmedia-dev@lists.sourceforge.net, netdev@vger.kernel.org
To: Magnus Damm <damm@igel.co.jp>, Jeff Garzik <jeff@garzik.org>,
	lethal@linux-sh.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756800AbXKKJHB@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 8687991a734a67f1638782c968f46fff0f94bb1f causes the following 
compile error on sh64:

<--  snip  -->

...
  CC [M]  drivers/net/ax88796.o
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/ax88796.c: In function 'ax_get_8390_hdr':
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/ax88796.c:187: error: implicit declaration of function 'readsw'
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/ax88796.c:189: error: implicit declaration of function 'readsb'
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/ax88796.c: In function 'ax_block_output':
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/ax88796.c:275: error: implicit declaration of function 'writesw'
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/ax88796.c:277: error: implicit declaration of function 'writesb'
make[3]: *** [drivers/net/ax88796.o] Error 1

<--  snip -->


cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
