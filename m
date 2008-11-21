From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH net-next 2/2] netdevice pc300: Add the reason about PC300
 BROKEN in Kconfig
Date: Fri, 21 Nov 2008 17:02:59 +0800
Message-ID: <49267943.6010804@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Krzysztof Halasa <khc@pm.waw.pl>, Alan Cox <alan@redhat.com>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49184 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752818AbYKUJDP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 04:03:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When compile test my previous patch, I found PC300 driver was broken.
And there is no explanation about the broken.
Add the reason about why change this driver to broken in Kconfig.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/wan/Kconfig |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
index 21efd99..0725161 100644
--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
@@ -207,6 +207,8 @@ config PC300
 	tristate "Cyclades-PC300 support (RS-232/V.35, X.21, T1/E1 boards)"
 	depends on HDLC && PCI && BROKEN
 	---help---
+	  This driver is broken because of struct tty_driver change.
+
 	  Driver for the Cyclades-PC300 synchronous communication boards.
 
 	  These boards provide synchronous serial interfaces to your
-- 
1.5.3.4




