From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 6/6] be2net: remove one useless line
Date: Fri, 18 Mar 2011 18:51:02 +0530
Message-ID: <d1a652b4-42ad-4f4d-80a5-3e5dfdc4d320@exht1.ad.emulex.com>
References: <1300454462-1234-1-git-send-email-sathya.perla@emulex.com>
 <1300454462-1234-2-git-send-email-sathya.perla@emulex.com>
 <1300454462-1234-3-git-send-email-sathya.perla@emulex.com>
 <1300454462-1234-4-git-send-email-sathya.perla@emulex.com>
 <1300454462-1234-5-git-send-email-sathya.perla@emulex.com>
 <1300454462-1234-6-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:9939 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756553Ab1CRNVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 09:21:39 -0400
In-Reply-To: <1300454462-1234-6-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index acd53e6..cfe986f 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2325,7 +2325,6 @@ static int be_setup(struct be_adapter *adapter)
 
 	return 0;
 
-	be_mcc_queues_destroy(adapter);
 rx_qs_destroy:
 	be_rx_queues_destroy(adapter);
 tx_qs_destroy:
-- 
1.6.5.2

