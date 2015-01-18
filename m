From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 0/2] bgmac: some fixes to napi usage
Date: Sun, 18 Jan 2015 19:49:57 +0100
Message-ID: <1421606999-23692-1-git-send-email-hauke@hauke-m.de>
Cc: netdev@vger.kernel.org, Hauke Mehrtens <hauke@hauke-m.de>
To: zajec5@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hauke-m.de ([5.39.93.123]:33039 "EHLO hauke-m.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750910AbbARSul (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jan 2015 13:50:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I compared the napi documentation with the bgmac driver and found some 
problems in that driver. These two patches should fix the problems.

Hauke Mehrtens (2):
  bgmac: register napi before the device
  bgmac: activate irqs only if there is nothing to poll

 drivers/net/ethernet/broadcom/bgmac.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

-- 
1.9.1
