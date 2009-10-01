From: Ralf Baechle <ralf@linux-mips.org>
Subject: NET: mkiss: Fix typo
Date: Thu, 1 Oct 2009 23:42:18 +0200
Message-ID: <20091001214218.GA15050@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matti Aarnio <matti.aarnio@zmailer.org>,
	Thomas Osterried <thomas@x-berg.in-berlin.de>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andreas Koensgen <ajk@comnets.uni-bremen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:52217 "EHLO
	eddie.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482AbZJAVlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 17:41:19 -0400
Received: from localhost.localdomain ([127.0.0.1]:46344 "EHLO h5.dl5rb.org.uk"
	rhost-flags-OK-OK-OK-FAIL) by ftp.linux-mips.org with ESMTP
	id S1493490AbZJAVlU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 23:41:20 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This typo was introduced by 5793f4be23f0171b4999ca68a39a9157b44139f3 on
October 14, 2005 ...

Reported-by: Matti Aarnio <matti.aarnio@zmailer.org>
Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 drivers/net/hamradio/mkiss.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index 33b55f7..db4b7f1 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -258,7 +258,7 @@ static void ax_bump(struct mkiss *ax)
 			}
 			if (ax->crcmode != CRC_MODE_SMACK && ax->crcauto) {
 				printk(KERN_INFO
-				       "mkiss: %s: Switchting to crc-smack\n",
+				       "mkiss: %s: Switching to crc-smack\n",
 				       ax->dev->name);
 				ax->crcmode = CRC_MODE_SMACK;
 			}
@@ -272,7 +272,7 @@ static void ax_bump(struct mkiss *ax)
 			}
 			if (ax->crcmode != CRC_MODE_FLEX && ax->crcauto) {
 				printk(KERN_INFO
-				       "mkiss: %s: Switchting to crc-flexnet\n",
+				       "mkiss: %s: Switching to crc-flexnet\n",
 				       ax->dev->name);
 				ax->crcmode = CRC_MODE_FLEX;
 			}
