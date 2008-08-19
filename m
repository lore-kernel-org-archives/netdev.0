From: Adrian Bunk <bunk@kernel.org>
Subject: frv must provide ioremap_wc
Date: Tue, 19 Aug 2008 16:48:01 +0300
Message-ID: <20080819134801.GI8852@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, Brice Goglin <brice@myri.com>,
	netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:39717 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756418AbYHSNsN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 09:48:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<--  snip  -->

...
  CC      drivers/net/myri10ge/myri10ge.o
myri10ge.c: In function 'myri10ge_probe':
myri10ge.c:3725: error: implicit declaration of function 'ioremap_wc'
...
make[4]: *** [drivers/net/myri10ge/myri10ge.o] Error 1

<--  snip  -->

http://kerneltrap.org/mailarchive/linux-netdev/2008/8/11/2889824/thread 
contains a discussion of the same problem on ARM.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

