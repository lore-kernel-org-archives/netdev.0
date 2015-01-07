From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 00/11]r8169:update hardware parameter
Date: Thu, 8 Jan 2015 00:40:15 +0800
Message-ID: <1420648826-12972-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:41846 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753861AbbAGQke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 11:40:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These series of patch include the ephy update of following adapters.
rtl8411
rtl8168f
rtl8168evl
rtl8168dp
rtl8105
rtl8402

Jumbo frame patch update of following adapters.
rtl8168dp
rtl8168e
rtl8168evl

Also remove unnecessary function rtl_hw_start_8168dp. And add function
rtl_hw_start_8168f_2 to set rtl8168f rev.b ephy paramerers.

Chunhao Lin (11):
  r8169:change rtl8168dp jumbo frame patch
  r8169:update rtl8168e and rtl8168evl jumbo frame patch
  r8169:change the way of setting rtl8168dp ephy parameters.
  r8169:update rtl8168dp pcie ephy parameter
  r8169:remove function rtl_hw_start_8168dp
  r8169:update rtl8168evl pcie ephy parameter
  r8169:update rtl8168f pcie ephy parameter
  r8169:update rtl8411 pcie ephy parameter
  r8169:update rtl8105e pcie ephy parameter
  r8169:update rtl8402 pcie ephy parameter
  r8169:update rtl8168f rev.b pcie ephy parameter

 drivers/net/ethernet/realtek/r8169.c | 112 +++++++++++++++--------------------
 1 file changed, 49 insertions(+), 63 deletions(-)

-- 
1.9.1
