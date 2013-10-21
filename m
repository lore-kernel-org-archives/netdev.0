From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 00/15] net: ethernet: remove unnecessary pci_set_drvdata() part
 2
Date: Mon, 21 Oct 2013 11:08:21 +0900
Message-ID: <003801cece02$6abb0160$40310420$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:50753 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101Ab3JUCIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 22:08:32 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUZ00L7BXXV07F0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Mon, 21 Oct 2013 11:08:22 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound),
the driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

---
 drivers/net/ethernet/dec/tulip/de2104x.c         |    1 -
 drivers/net/ethernet/dec/tulip/dmfe.c            |    3 ---
 drivers/net/ethernet/dec/tulip/tulip_core.c      |    1 -
 drivers/net/ethernet/dec/tulip/uli526x.c         |    2 --
 drivers/net/ethernet/dec/tulip/winbond-840.c     |    3 ---
 drivers/net/ethernet/dec/tulip/xircom_cb.c       |    2 --
 drivers/net/ethernet/dlink/dl2k.c                |    1 -
 drivers/net/ethernet/dlink/sundance.c            |    2 --
 drivers/net/ethernet/emulex/benet/be_main.c      |    2 --
 drivers/net/ethernet/fealnx.c                    |    1 -
 drivers/net/ethernet/icplus/ipg.c                |    1 -
 drivers/net/ethernet/intel/e100.c                |    2 --
 drivers/net/ethernet/jme.c                       |    2 --
 drivers/net/ethernet/marvell/skge.c              |    2 --
 drivers/net/ethernet/marvell/sky2.c              |    3 ---
 drivers/net/ethernet/micrel/ksz884x.c            |    2 --
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |    1 -
 drivers/net/ethernet/natsemi/natsemi.c           |    2 --
 drivers/net/ethernet/neterion/s2io.c             |    2 --
 drivers/net/ethernet/neterion/vxge/vxge-main.c   |    2 --
 drivers/net/ethernet/packetengines/hamachi.c     |    1 -
 drivers/net/ethernet/packetengines/yellowfin.c   |    2 --
 22 files changed, 40 deletions(-)
