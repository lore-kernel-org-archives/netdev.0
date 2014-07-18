From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [PATCH net,stable] net: huawei_cdc_ncm: add "subclass 3"
 devices
Date: Fri, 18 Jul 2014 17:14:39 +0200 (CEST)
Message-ID: <alpine.LNX.2.03.1407181713530.687@gmail.com>
References: <1405596849-11800-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-681086170-1405696481=:687"
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:43521 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761804AbaGRPNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2014 11:13:49 -0400
In-Reply-To: <1405596849-11800-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-681086170-1405696481=:687
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

Seems interesting
That's fine.

Acked-By: Enrico Mioso <mrkiko.rs@gmail.com>

On Thu, 17 Jul 2014, Bjørn Mork wrote:

==Date: Thu, 17 Jul 2014 13:34:09
==From: Bjørn Mork <bjorn@mork.no>
==To: netdev@vger.kernel.org
==Cc: linux-usb@vger.kernel.org, Bjørn Mork <bjorn@mork.no>,
==    Enrico Mioso <mrkiko.rs@gmail.com>
==Subject: [PATCH net,stable] net: huawei_cdc_ncm: add "subclass 3" devices
==
==Huawei's usage of the subclass and protocol fields is not 100%
==clear to us, but there appears to be a very strict system.
==
==A device with the "shared" device ID 12d1:1506 and this NCM
==function was recently reported (showing only default altsetting):
==
==    Interface Descriptor:
==      bLength                 9
==      bDescriptorType         4
==      bInterfaceNumber        1
==      bAlternateSetting       0
==      bNumEndpoints           1
==      bInterfaceClass       255 Vendor Specific Class
==      bInterfaceSubClass      3
==      bInterfaceProtocol     22
==      iInterface              8 CDC Network Control Model (NCM)
==      ** UNRECOGNIZED:  05 24 00 10 01
==      ** UNRECOGNIZED:  06 24 1a 00 01 1f
==      ** UNRECOGNIZED:  0c 24 1b 00 01 00 04 10 14 dc 05 20
==      ** UNRECOGNIZED:  0d 24 0f 0a 0f 00 00 00 ea 05 03 00 01
==      ** UNRECOGNIZED:  05 24 06 01 01
==      Endpoint Descriptor:
==        bLength                 7
==        bDescriptorType         5
==        bEndpointAddress     0x85  EP 5 IN
==        bmAttributes            3
==          Transfer Type            Interrupt
==          Synch Type               None
==          Usage Type               Data
==        wMaxPacketSize     0x0010  1x 16 bytes
==        bInterval               9
==
==Cc: Enrico Mioso <mrkiko.rs@gmail.com>
==Signed-off-by: Bjørn Mork <bjorn@mork.no>
==---
== drivers/net/usb/huawei_cdc_ncm.c | 3 +++
== 1 file changed, 3 insertions(+)
==
==diff --git a/drivers/net/usb/huawei_cdc_ncm.c b/drivers/net/usb/huawei_cdc_ncm.c
==index 5d95a13dbe2a..735f7dadb9a0 100644
==--- a/drivers/net/usb/huawei_cdc_ncm.c
==+++ b/drivers/net/usb/huawei_cdc_ncm.c
==@@ -194,6 +194,9 @@ static const struct usb_device_id huawei_cdc_ncm_devs[] = {
== 	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x76),
== 	  .driver_info = (unsigned long)&huawei_cdc_ncm_info,
== 	},
==+	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x03, 0x16),
==+	  .driver_info = (unsigned long)&huawei_cdc_ncm_info,
==+	},
== 
== 	/* Terminating entry */
== 	{
==-- 
==2.0.1
==
==
--8323328-681086170-1405696481=:687--
