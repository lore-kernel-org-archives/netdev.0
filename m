From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH (RESEND)] [USBNET] DM9601: Add Corega FEther USB-TXC
 support.
Date: Thu, 01 Mar 2007 16:52:05 +0900 (JST)
Message-ID: <20070301.165205.78649434.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33735 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339AbXCAHvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 02:51:45 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/usb/net/dm9601.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/usb/net/dm9601.c b/drivers/usb/net/dm9601.c
index 4a932e1..c0bc52b 100644
--- a/drivers/usb/net/dm9601.c
+++ b/drivers/usb/net/dm9601.c
@@ -571,6 +571,10 @@ static const struct driver_info dm9601_info = {
 
 static const struct usb_device_id products[] = {
 	{
+	 USB_DEVICE(0x07aa, 0x9601),	/* Corega FEther USB-TXC */
+	 .driver_info = (unsigned long)&dm9601_info,
+	 },
+	{
 	 USB_DEVICE(0x0a46, 0x9601),	/* Davicom USB-100 */
 	 .driver_info = (unsigned long)&dm9601_info,
 	 },

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
