From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 03/05] r8169: revert
	7da97ec96a0934319c7fbedd3d38baf533e20640 (partly)
Date: Fri, 9 Nov 2007 00:10:24 +0100
Message-ID: <20071108231024.GD15968@electric-eye.fr.zoreil.com>
References: <20071108230734.GA15968@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Mark Lord <mlord@pobox.com>,
	Ciaran McCreesh <ciaran.mccreesh@blueyonder.co.uk>,
	Josh Logan <joshtlogan@gmail.com>,
	cecco <f.cecco77@tiscali.it>,
	Hans-Jurgen Koch <hjk@linutronix.de>,
	David Gundersen <gundy@iinet.net.au>,
	Will Trives <will@trivescon.com.au>,
	"Alexander Y. Fomichev" <gluk@php4.ru>,
	Rolf Eike Beer <eike-kernel@sf-tec.de>,
	Daniel Drake <dsd@gentoo.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Philip Craig <philipc@snapgear.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38773 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753539AbXKHXQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 18:16:10 -0500
Content-Disposition: inline
In-Reply-To: <20071108230734.GA15968@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Various symptoms depending on the .config options:
- the card stops working after some (short) time
- the card does not work at all
- the card disappears (nothing in lspci/dmesg)

A real power-off is needed to recover the card.

Signed-off-by: Mark Lord <mlord@pobox.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 9dbab3f..a37cf82 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1328,6 +1328,7 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		break;
 	case RTL_GIGA_MAC_VER_11:
 	case RTL_GIGA_MAC_VER_12:
+		break;
 	case RTL_GIGA_MAC_VER_17:
 		rtl8168b_hw_phy_config(ioaddr);
 		break;
-- 
1.5.3.3

