From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 3/4] samples/pktgen: update sample03,
 no need for clones when bursting
Date: Wed, 01 Nov 2017 11:41:19 +0100
Message-ID: <150953287937.29671.3484376439222598253.stgit@firesoul>
References: <150953283424.29671.6809291616813585256.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <robert@herjulf.se>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        robert.hu@intel.com, pabeni@redhat.com, kafai@fb.com,
        tariqt@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49270 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753637AbdKAKlX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 06:41:23 -0400
In-Reply-To: <150953283424.29671.6809291616813585256.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like sample05, don't use pktgen clone_skb feature when using 'burst' feature,
it is not really needed.  This brings the burst users in sync.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 .../pktgen/pktgen_sample03_burst_single_flow.sh    |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/samples/pktgen/pktgen_sample03_burst_single_flow.sh b/samples/pktgen/pktgen_sample03_burst_single_flow.sh
index 8d26e0ca683d..8a46daf27966 100755
--- a/samples/pktgen/pktgen_sample03_burst_single_flow.sh
+++ b/samples/pktgen/pktgen_sample03_burst_single_flow.sh
@@ -30,7 +30,7 @@ if [ -z "$DEST_IP" ]; then
 fi
 [ -z "$DST_MAC" ]   && DST_MAC="90:e2:ba:ff:ff:ff"
 [ -z "$BURST" ]     && BURST=32
-[ -z "$CLONE_SKB" ] && CLONE_SKB="100000"
+[ -z "$CLONE_SKB" ] && CLONE_SKB="0" # No need for clones when bursting
 [ -z "$COUNT" ]     && COUNT="0" # Zero means indefinitely
 
 # Base Config
