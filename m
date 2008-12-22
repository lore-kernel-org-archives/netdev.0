From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 26/27] drivers/net/wireless/ipw2x00: fix sparse warnings: make
	symbols static
Date: Mon, 22 Dec 2008 20:18:51 +0100
Message-ID: <20081222191851.11807.885.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.185]:31751 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755501AbYLVTS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:18:57 -0500
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:

  drivers/net/wireless/ipw2x00/ipw2100.c:5271:6: warning: symbol 'ipw2100_queues_initialize' was not declared. Should it be static?
  drivers/net/wireless/ipw2x00/ipw2100.c:5278:6: warning: symbol 'ipw2100_queues_free' was not declared. Should it be static?
  drivers/net/wireless/ipw2x00/ipw2100.c:5285:5: warning: symbol 'ipw2100_queues_allocate' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/wireless/ipw2x00/ipw2100.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 2d2044d..1667065 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -5268,21 +5268,21 @@ static int ipw2100_set_ibss_beacon_interval(struct ipw2100_priv *priv,
 	return 0;
 }
 
-void ipw2100_queues_initialize(struct ipw2100_priv *priv)
+static void ipw2100_queues_initialize(struct ipw2100_priv *priv)
 {
 	ipw2100_tx_initialize(priv);
 	ipw2100_rx_initialize(priv);
 	ipw2100_msg_initialize(priv);
 }
 
-void ipw2100_queues_free(struct ipw2100_priv *priv)
+static void ipw2100_queues_free(struct ipw2100_priv *priv)
 {
 	ipw2100_tx_free(priv);
 	ipw2100_rx_free(priv);
 	ipw2100_msg_free(priv);
 }
 
-int ipw2100_queues_allocate(struct ipw2100_priv *priv)
+static int ipw2100_queues_allocate(struct ipw2100_priv *priv)
 {
 	if (ipw2100_tx_allocate(priv) ||
 	    ipw2100_rx_allocate(priv) || ipw2100_msg_allocate(priv))

