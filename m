From: Daniele Palmas <dnlplm@gmail.com>
Subject: [PATCH v2 0/2] net: usb: cdc_ncm: Adding support for two new Dell devices
Date: Fri, 18 Dec 2015 14:43:32 +0100
Message-ID: <1450446214-22948-1-git-send-email-dnlplm@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Daniele Palmas <dnlplm@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:33881 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932129AbbLRNnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 08:43:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series add support in the cdc_ncm driver for two devices
based on the same platform, that are different only for carrier
customization.

V2: Added comment for highlighting FLAG_NOARP usage for those devices

Daniele Palmas (2):
  net: usb: cdc_ncm: Adding Dell DW5812 LTE Verizon Mobile Broadband
    Card
  net: usb: cdc_ncm: Adding Dell DW5813 LTE AT&T Mobile Broadband Card

 drivers/net/usb/cdc_ncm.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

-- 
1.9.1
