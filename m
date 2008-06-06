From: Adrian Bunk <bunk@kernel.org>
Subject: blackfin drivers/net/smc91x.c build error
Date: Fri, 6 Jun 2008 19:22:12 +0300
Message-ID: <20080606162212.GC2201@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bryan Wu <cooloney@kernel.org>, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:36000 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760982AbYFFQWx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2008 12:22:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/smc91x.c fails as follows on blackfin:

<--  snip  -->

...
  CC      drivers/net/smc91x.o
...
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/smc91x.c:1863:36: error: macro "SMC_GET_MAC_ADDR" passed 2 arguments, but takes just 1
...
make[3]: *** [drivers/net/smc91x.o] Error 1

<--  snip  -->

The required action seems to be a revert of:
commit 099c736a470c8080a166e7a089f1e48e15f9947c
(Revert "smc91x: fix build breakage from the SMC_GET_MAC_ADDR API upgrade") (sic).

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

