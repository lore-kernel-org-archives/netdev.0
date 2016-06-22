From: Andy Duan <fugang.duan@nxp.com>
Subject: [PATCH net-next 0/2] net: fec: add new type device
Date: Wed, 22 Jun 2016 18:52:34 +0800
Message-ID: <1466592756-11239-1-git-send-email-fugang.duan@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <stephen@networkplumber.org>,
	<fugang.duan@nxp.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0080.outbound.protection.outlook.com ([65.55.169.80]:6376
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751453AbcFVL1l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 07:27:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Different i.MX SOC FEC support different features like :
    - i.MX6Q/DL FEC does not support AVB and interrupt coalesc
    - i.MX6SX/i.MX7D supports AVB and interrupt coalesc
    - i.MX6UL/ULL does not support AVB, but support interrupt coalesc

Then, add new quirk flag to judge the supported features, and add new
type device for i.MX6UL.

Andy Duan (2):
  net: fec: add interrupt coalesc quirk flag
  net: fec: use a more proper compatible string for i.MX6UL type device

 drivers/net/ethernet/freescale/fec.h      |  2 ++
 drivers/net/ethernet/freescale/fec_main.c | 27 +++++++++++++++++----------
 2 files changed, 19 insertions(+), 10 deletions(-)

-- 
1.9.1
