From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net 1/1] r8169: enforce RX_MULTI_EN for the 8168f.
Date: Sun, 8 Sep 2013 01:15:35 +0200
Message-ID: <20130907231535.GB24530@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	David R <david@unsolicited.net>,
	=?utf-8?B?RnLDqWTDqXJpYw==?= Leroy <fredo@starox.org>,
	Hayes Wang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51551 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758Ab3IGXPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 19:15:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Same narrative as eb2dc35d99028b698cdedba4f5522bc43e576bd2 ("r8169: RxC=
onfig
hack for the 8168evl.") regarding AMD IOMMU errors.

RTL_GIGA_MAC_VER_36 - 8168f as well - has not been reported to behave t=
he
same.

Tested-by: David R <david@unsolicited.net>
Tested-by: Fr=C3=A9d=C3=A9ric Leroy <fredo@starox.org>
Cc: Hayes Wang <hayeswang@realtek.com>
---

 Hayes, a ack would be welcome.

 drivers/net/ethernet/realtek/r8169.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/etherne=
t/realtek/r8169.c
index 6f87f2c..3397cee 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4231,6 +4231,7 @@ static void rtl_init_rxcfg(struct rtl8169_private=
 *tp)
 	case RTL_GIGA_MAC_VER_23:
 	case RTL_GIGA_MAC_VER_24:
 	case RTL_GIGA_MAC_VER_34:
+	case RTL_GIGA_MAC_VER_35:
 		RTL_W32(RxConfig, RX128_INT_EN | RX_MULTI_EN | RX_DMA_BURST);
 		break;
 	case RTL_GIGA_MAC_VER_40:
--=20
1.8.3.1
