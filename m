From: Ian Coolidge <iancoolidge@gmail.com>
Subject: [PATCH 0/2] Fix CDC_EEM with 802.1Q VLAN and 1500 MTU
Date: Tue,  6 Nov 2012 13:00:09 -0800
Message-ID: <1352235611-13066-1-git-send-email-iancoolidge@gmail.com>
Cc: Ian Coolidge <iancoolidge@gmail.com>
To: Oliver Neukum <oliver@neukum.name>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Felipe Balbi <balbi@ti.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:53612 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870Ab2KFU7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 15:59:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cdc_eem USB host driver and gadget driver both are broken in 1500 MTU
case when using 802.1Q VLANs. In both cases, this is due to incomplete
assumptions of Ethernet frame size.

Ian Coolidge (2):
  usb: gadget: g_ether: fix frame size check
  net: usb: cdc_eem: Fix rx skb allocation for 802.1Q VLANs

 drivers/net/usb/cdc_eem.c    |    4 ++++
 drivers/usb/gadget/u_ether.c |    3 ++-
 2 files changed, 6 insertions(+), 1 deletions(-)

-- 
1.7.6.5
