From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 0/7] net: ethernet: remove unnecessary pci_set_drvdata() part 4
Date: Wed, 23 Oct 2013 16:05:34 +0900
Message-ID: <000001cecfbe$44ce9c10$ce6bd430$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:14876 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949Ab3JWHFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 03:05:39 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MV400EU810XD7O0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Wed, 23 Oct 2013 16:05:35 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound),
the driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

---
 drivers/net/ethernet/sun/niu.c            |    2 --
 drivers/net/ethernet/sun/sungem.c         |    2 --
 drivers/net/ethernet/tehuti/tehuti.c      |    1 -
 drivers/net/ethernet/ti/tlan.c            |    1 -
 drivers/net/ethernet/toshiba/spider_net.c |    1 -
 drivers/net/ethernet/toshiba/tc35815.c    |    1 -
 drivers/net/ethernet/via/via-rhine.c      |    1 -
 7 files changed, 9 deletions(-)
