From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH v2 0/3] net: ti: netcp: restore get/set_pad_info() functionality
Date: Fri, 19 Feb 2016 12:58:41 -0500
Message-ID: <1455904724-17952-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series fixes a regression and add some improvements for the ease
of maintainance. Incorporated comments against v1.

Changelogs:
 
 v2 : combined 2-3 into one patch as this involves a header change
      fixed a parse warning in 3/4 per comment from Arnd.
      Removed Sign-off from Arnd against 1/4
      added comments in 3/3 to alert on the usage of sw data per review
      comments
 v1 : added 2-4 to accomodate feedback received from review
 v0 : initial version to fix the regression (From Grygorii) 

Murali Karicheri (3):
  net: ti: netcp: restore get/set_pad_info() functionality
  soc: ti: knav_dma: rename pad in struct knav_dma_desc to sw_data
  net: netcp: rework the code for get/set sw_data in dma desc

 drivers/net/ethernet/ti/netcp_core.c | 105 ++++++++++++++++++++---------------
 include/linux/soc/ti/knav_dma.h      |   4 +-
 2 files changed, 64 insertions(+), 45 deletions(-)

-- 
1.9.1
