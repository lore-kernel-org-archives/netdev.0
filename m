From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 0/2] IPv6 NFC
Date: Tue, 2 Feb 2016 18:47:04 +0000
Message-ID: <56B0F9A8.7010202@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:2568 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755898AbcBBSrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 13:47:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds support for steering IPv6 flows using the ethtool NFC
 interface, and implements it for sfc devices.
Tested using an in-development patch to the ethtool utility.

Edward Cree (2):
  ethtool: add IPv6 to the NFC API
  sfc: implement IPv6 NFC (and IPV4_USER_FLOW)

 drivers/net/ethernet/sfc/ethtool.c | 176 +++++++++++++++++++++++++++++++++++++
 include/uapi/linux/ethtool.h       |  70 +++++++++++++--
 2 files changed, 240 insertions(+), 6 deletions(-)
