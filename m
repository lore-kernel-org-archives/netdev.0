From: Adrian Bunk <bunk@kernel.org>
Subject: drivers/s390/net/qeth_l3_main.c build error
Date: Mon, 21 Jul 2008 13:55:53 +0300
Message-ID: <20080721105553.GB22914@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Frank Blaschka <frank.blaschka@de.ibm.com>,
	Jeff Garzik <jeff@garzik.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:51490 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752040AbYGUKz6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 06:55:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 6aa895b047720f71ec4eb11452f7c3ce8426941f
(vlan: Don't store VLAN tag in cb) causes the following build error:

<--  snip  -->

...
  CC      drivers/s390/net/qeth_l3_main.o
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/s390/net/qeth_l3_main.c: In function 'qeth_l3_hard_start_xmit':
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/s390/net/qeth_l3_main.c:2654: error: implicit declaration of function 'VLAN_TX_SKB_CB'
/home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/s390/net/qeth_l3_main.c:2654: error: invalid type argument of '->' (have 'int')
make[3]: *** [drivers/s390/net/qeth_l3_main.o] Error 1

<--  snip  -->


cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed


