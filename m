From: Fugang Duan <fugang.duan@nxp.com>
Subject: [PATCH net-next 0/6] net: fec: driver code clean
Date: Tue, 11 Apr 2017 19:13:02 +0800
Message-ID: <1491909188-8971-1-git-send-email-fugang.duan@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
        <stephen@networkplumber.org>, <fugang.duan@nxp.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0075.outbound.protection.outlook.com ([104.47.36.75]:16288
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753246AbdDKLPO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 07:15:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch series are for fec ethernet driver code clean up, each patch is
independent.
Patch #1,#4,#5 are code clean up.
Patch #2,#3 are for aarch64 platform.
Patch #6 is for i.MX6UL to add lost errata workaround.


Fugang Duan (6):
  net: fec: add return value check after calling .of_property_read_u32()
  net: fec: avoid BD pointer type cast to 32bit
  net: fec: pass ->dev to dma_alloc/free__coherent() API
  net: fec: add phy-reset-gpios PROBE_DEFER check
  net: fec: correct the errata number comment typo
  net: fec: add ERR007885 for i.MX6ul enet IP

 drivers/net/ethernet/freescale/fec_main.c | 45 +++++++++++++++++++------------
 1 file changed, 28 insertions(+), 17 deletions(-)

-- 
1.9.1
