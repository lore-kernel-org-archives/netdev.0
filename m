From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 00/15] net: ethernet: remove unnecessary pci_set_drvdata() part
 1
Date: Fri, 18 Oct 2013 09:16:19 +0900
Message-ID: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:57358 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753337Ab3JRAQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 20:16:21 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUU00JXS8P1OPC0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Fri, 18 Oct 2013 09:16:20 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound),
the driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

---
 drivers/net/ethernet/3com/typhoon.c                 |    1 -
 drivers/net/ethernet/8390/ne2k-pci.c                |    3 ---
 drivers/net/ethernet/adaptec/starfire.c             |    2 --
 drivers/net/ethernet/amd/amd8111e.c                 |    2 --
 drivers/net/ethernet/amd/pcnet32.c                  |    1 -
 drivers/net/ethernet/atheros/alx/main.c             |    1 -
 drivers/net/ethernet/broadcom/bnx2.c                |    3 ---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c    |    3 ---
 drivers/net/ethernet/broadcom/tg3.c                 |    2 --
 drivers/net/ethernet/brocade/bna/bnad.c             |    1 -
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c           |    2 --
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c     |    2 --
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c     |    2 --
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c |    3 ---
 drivers/net/ethernet/cisco/enic/enic_main.c         |    2 --
 15 files changed, 30 deletions(-)
