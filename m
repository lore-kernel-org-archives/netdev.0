From: "ASIX_Allan [Office]" <allan@asix.com.tw>
Subject: [PATCH] drivers/net/usb/ax88179_178a: added Cypress GX3 VID_04b4/PID_3610
Date: Tue, 1 Dec 2015 09:16:10 +0800
Message-ID: <00a201d12bd5$e1069b30$a313d190$@asix.com.tw>
Reply-To: <allan@asix.com.tw>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="big5"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"'Grant Grundler'" <grundler@chromium.org>,
	"'Eugene'" <elubarsky@gmail.com>,
	=?big5?B?J0FTSVggTG91aXMgW8Ssq8KzsF0n?= <louis@asix.com.tw>,
	"'Jegannathan Ramanujam'" <jega@cypress.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: zh-tw
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Added to support Cypress GX3 SuperSpeed to Gigabit Ethernet Bridge
Controller (VID_04b4/PID_3610). 

Signed-off-by: Allan Chou <allan@asix.com.tw>
Tested-by: Allan Chou <allan@asix.com.tw>
---
This patch had been verified on x86 Linux kernel 4.1.6 system with Cypress
GX3 SuperSpeed to Gigabit Ethernet Bridge Controller (VID_04b4/PID_3610)
dongle. 

diff -Naur a/ax88179_178a.c b/ax88179_178a.c
--- a/ax88179_178a.c     2015-08-17 11:52:51.000000000 +0800
+++ b/ax88179_178a.c   2015-11-30 16:44:31.311674000 +0800
@@ -1708,6 +1708,21 @@
      .tx_fixup = ax88179_tx_fixup,
};

+static const struct driver_info cypress_GX3_info = {
+      .description = "Cypress GX3 SuperSpeed to Gigabit Ethernet Bridge
Controller",
+      .bind = ax88179_bind,
+      .unbind = ax88179_unbind,
+      .status = ax88179_status,
+      .link_reset = ax88179_link_reset,
+      .reset = ax88179_reset,
+      .stop = ax88179_stop,
+      .flags = FLAG_ETHER | FLAG_FRAMING_AX,
+      .rx_fixup = ax88179_rx_fixup,
+      .tx_fixup = ax88179_tx_fixup,
+};
+
+
+
static const struct usb_device_id products[] = {
{
      /* ASIX AX88179 10/100/1000 */
@@ -1733,6 +1748,10 @@
      /* Lenovo OneLinkDock Gigabit LAN */
      USB_DEVICE(0x17ef, 0x304b),
      .driver_info = (unsigned long)&lenovo_info,
+}, {
+      /* Cypress GX3 SuperSpeed to Gigabit Ethernet Bridge Controller */
+      USB_DEVICE(0x04b4, 0x3610),
+      .driver_info = (unsigned long)&cypress_GX3_info,
},
      { },
};



---
Best regards,
Allan Chou
Technical Support Division
ASIX Electronics Corporation
TEL: 886-3-5799500 ext.228
FAX: 886-3-5799558
E-mail: allan@asix.com.tw 
http://www.asix.com.tw/ 
