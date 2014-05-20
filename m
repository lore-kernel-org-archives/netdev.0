From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: doc: Update references to skb->rxhash
Date: Tue, 20 May 2014 13:52:13 +0200
Message-ID: <1400586733-21047-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org, linux-doc@vger.kernel.org
To: Randy Dunlap <rdunlap@infradead.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:60435 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752946AbaETLwQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 07:52:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 61b905da33 ("net: Rename skb->rxhash to skb->hash"), skb->rxhash
was renamed to skb->hash. Update references in Documentation
accordingly.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 Documentation/networking/filter.txt      |    2 +-
 Documentation/networking/packet_mmap.txt |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index 748fd38..7d82686 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -277,7 +277,7 @@ Possible BPF extensions are shown in the following table:
   mark                                  skb->mark
   queue                                 skb->queue_mapping
   hatype                                skb->dev->type
-  rxhash                                skb->rxhash
+  rxhash                                skb->hash
   cpu                                   raw_smp_processor_id()
   vlan_tci                              vlan_tx_tag_get(skb)
   vlan_pr                               vlan_tx_tag_present(skb)
diff --git a/Documentation/networking/packet_mmap.txt b/Documentation/networking/packet_mmap.txt
index 6fea79e..38112d5 100644
--- a/Documentation/networking/packet_mmap.txt
+++ b/Documentation/networking/packet_mmap.txt
@@ -578,7 +578,7 @@ processes. This also works in combination with mmap(2) on packet sockets.
 
 Currently implemented fanout policies are:
 
-  - PACKET_FANOUT_HASH: schedule to socket by skb's rxhash
+  - PACKET_FANOUT_HASH: schedule to socket by skb's packet hash
   - PACKET_FANOUT_LB: schedule to socket by round-robin
   - PACKET_FANOUT_CPU: schedule to socket by CPU packet arrives on
   - PACKET_FANOUT_RND: schedule to socket by random selection
-- 
1.7.9.5
