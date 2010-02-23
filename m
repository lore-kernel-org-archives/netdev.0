From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] e1000: correct wrong coding style for "else"
Date: Tue, 23 Feb 2010 09:48:08 +0100
Message-ID: <20100223084808.GB2610@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse.brandeburg@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27250 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751111Ab0BWIsN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2010 03:48:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/e1000/e1000_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index c99f95c..319c2b5 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2170,8 +2170,7 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 			hash_bit = hash_value & 0x1F;
 			mta = (1 << hash_bit);
 			mcarray[hash_reg] |= mta;
-		}
-		else {
+		} else {
 			e1000_rar_set(hw, mc_ptr->da_addr, i++);
 		}
 	}
-- 
1.6.6

