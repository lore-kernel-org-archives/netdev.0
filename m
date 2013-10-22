From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 00/15] net: ethernet: remove unnecessary pci_set_drvdata() part
 3
Date: Tue, 22 Oct 2013 13:13:44 +0900
Message-ID: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:26366 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786Ab3JVENq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 00:13:46 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MV100BOKYDWWBK0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Tue, 22 Oct 2013 13:13:45 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound),
the driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

---
 drivers/net/ethernet/pasemi/pasemi_mac.c             |    1 -
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c |    2 --
 drivers/net/ethernet/qlogic/qla3xxx.c                |    2 --
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c     |    2 --
 drivers/net/ethernet/qlogic/qlge/qlge_main.c         |    1 -
 drivers/net/ethernet/rdc/r6040.c                     |    2 --
 drivers/net/ethernet/realtek/8139cp.c                |    1 -
 drivers/net/ethernet/realtek/8139too.c               |    1 -
 drivers/net/ethernet/realtek/r8169.c                 |    1 -
 drivers/net/ethernet/sis/sis190.c                    |    1 -
 drivers/net/ethernet/smsc/epic100.c                  |    1 -
 drivers/net/ethernet/smsc/smsc9420.c                 |    2 --
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c     |    1 -
 drivers/net/ethernet/sun/cassini.c                   |    2 --
 drivers/net/ethernet/sun/sunhme.c                    |    2 --
 15 files changed, 22 deletions(-)
