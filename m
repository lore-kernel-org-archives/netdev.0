From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH 0/2] Fix potential NULL pointer access and memory leak in ISDN layer2 functions
Date: Wed, 21 Oct 2015 14:18:37 +0200
Message-ID: <1445429919-22924-1-git-send-email-keil@b1-systems.de>
Cc: Karsten Keil <keil@b1-systems.de>, isdn@linux-pingi.de,
	netdev@vger.kernel.org, wuninsu@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.b1-systems.de ([84.200.69.220]:57422 "EHLO
	mx1.b1-systems.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbbJUMYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 08:24:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Insu Yun did brinup the issue with not checking the skb_clone() return
value in the layer2 I-frame ull functions.
This series fix the issue in a way which avoid protocol violations/data loss
on a temporary memory shortage.

Karsten Keil (2):
  ISDN: fix OOM condition for sending queued I-Frames
  mISDN: fix OOM condition for sending queued I-Frames

 drivers/isdn/hisax/isdnl2.c | 20 +++++++----------
 drivers/isdn/mISDN/layer2.c | 54 +++++++++++++++++----------------------------
 2 files changed, 28 insertions(+), 46 deletions(-)

-- 
2.1.4
