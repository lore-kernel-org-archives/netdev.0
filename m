From: Fengguang Wu <fengguang.wu@intel.com>
Subject: drivers/net/cris/eth_v10.c:1715:2: error: too many arguments to
 function 'e100rxtx_interrupt'
Date: Fri, 28 Sep 2012 21:06:08 +0800
Message-ID: <20120928130608.GA5158@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org
To: Jesper Nilsson <jesper.nilsson@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59265 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758059Ab2I1NGO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2012 09:06:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesper,

FYI, a rather old build bug that's introduced by

bafef0a cris build fixes: update eth_v10.c ethernet driver

All error/warnings:

drivers/net/cris/eth_v10.c: In function 'e100_netpoll':
drivers/net/cris/eth_v10.c:1715:2: error: too many arguments to function 'e100rxtx_interrupt'
drivers/net/cris/eth_v10.c:1131:1: note: declared here

vim +1715 drivers/net/cris/eth_v10.c

^1da177e (Linus Torvalds 2005-04-16  1710) 
bafef0ae (Jesper Nilsson 2007-11-14  1711) #ifdef CONFIG_NET_POLL_CONTROLLER
bafef0ae (Jesper Nilsson 2007-11-14  1712) static void
bafef0ae (Jesper Nilsson 2007-11-14  1713) e100_netpoll(struct net_device* netdev)
bafef0ae (Jesper Nilsson 2007-11-14  1714) {
bafef0ae (Jesper Nilsson 2007-11-14 @1715) 	e100rxtx_interrupt(NETWORK_DMA_TX_IRQ_NBR, netdev, NULL);
bafef0ae (Jesper Nilsson 2007-11-14  1716) }
bafef0ae (Jesper Nilsson 2007-11-14  1717) #endif
bafef0ae (Jesper Nilsson 2007-11-14  1718) 
^1da177e (Linus Torvalds 2005-04-16  1719) static int
^1da177e (Linus Torvalds 2005-04-16  1720) etrax_init_module(void)
^1da177e (Linus Torvalds 2005-04-16  1721) {
^1da177e (Linus Torvalds 2005-04-16  1722) 	return etrax_ethernet_init();
^1da177e (Linus Torvalds 2005-04-16  1723) }

---
0-DAY kernel build testing backend         Open Source Technology Centre
Fengguang Wu, Yuanhan Liu                              Intel Corporation
