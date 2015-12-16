From: Daniele Palmas <dnlplm@gmail.com>
Subject: [PATCH 0/2] net: usb: cdc_ncm: Adding support for two new Dell devices
Date: Wed, 16 Dec 2015 10:39:23 +0100
Message-ID: <1450258765-11215-1-git-send-email-dnlplm@gmail.com>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Daniele Palmas <dnlplm@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36404 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389AbbLPJjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 04:39:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series add support in the cdc_ncm driver for two devices
based on the same platform, that are different only for carrier
customization.

The devices do not have ARP capabilities.

Daniele Palmas (2):
  net: usb: cdc_ncm: Adding Dell DW5812 LTE Verizon Mobile Broadband
    Card
  net: usb: cdc_ncm: Adding Dell DW5813 LTE AT&T Mobile Broadband Card

 drivers/net/usb/cdc_ncm.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

-- 
1.9.1
