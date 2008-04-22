From: Adrian Bunk <bunk@kernel.org>
Subject: drivers/net/ucc_geth.c compile error
Date: Tue, 22 Apr 2008 21:49:19 +0300
Message-ID: <20080422184919.GE28933@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>,
	Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:45176 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755185AbYDVStz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2008 14:49:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 9d9326d3bc0ea9a8bbe40bf3e5e66c7b9858caa0
(phy: Change mii_bus id field to a string)
causes the following compile error:

<--  snip  -->

...
  CC      drivers/net/ucc_geth.o
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/ucc_geth.c: In function 'ucc_geth_startup':
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/ucc_geth.c:2605: warning: assignment makes integer from pointer without a cast
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/ucc_geth.c:2642: warning: assignment makes integer from pointer without a cast
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/ucc_geth.c: In function 'ucc_geth_probe':
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/ucc_geth.c:3935: error: incompatible types in assignment
make[3]: *** [drivers/net/ucc_geth.o] Error 1

<--  snip  -->

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

