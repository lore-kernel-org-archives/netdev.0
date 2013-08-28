From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/3] net: packet: document available fanout policies
Date: Wed, 28 Aug 2013 22:13:11 +0200
Message-ID: <1377720791-15844-4-git-send-email-dborkman@redhat.com>
References: <1377720791-15844-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27886 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755002Ab3H1UN0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 16:13:26 -0400
In-Reply-To: <1377720791-15844-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update documentation to add fanout policies that are available.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 Documentation/networking/packet_mmap.txt | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/Documentation/networking/packet_mmap.txt b/Documentation/networking/packet_mmap.txt
index 8572796..c012236 100644
--- a/Documentation/networking/packet_mmap.txt
+++ b/Documentation/networking/packet_mmap.txt
@@ -543,6 +543,14 @@ TPACKET_V2 --> TPACKET_V3:
 In the AF_PACKET fanout mode, packet reception can be load balanced among
 processes. This also works in combination with mmap(2) on packet sockets.
 
+Currently implemented fanout policies are:
+
+  - PACKET_FANOUT_HASH: schedule to socket by skb's rxhash
+  - PACKET_FANOUT_LB: schedule to socket by round-robin
+  - PACKET_FANOUT_CPU: schedule to socket by CPU packet arrives on
+  - PACKET_FANOUT_RND: schedule to socket by random selection
+  - PACKET_FANOUT_ROLLOVER: if one socket is full, rollover to another
+
 Minimal example code by David S. Miller (try things like "./test eth0 hash",
 "./test eth0 lb", etc.):
 
-- 
1.7.11.7
