From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] AF_PACKET: Add documentation for queue mapping fanout mode
Date: Mon, 27 Jan 2014 11:43:04 -0500
Message-ID: <1390840984-22246-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36809 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753842AbaA0QnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 11:43:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently I added a new AF_PACKET fanout operation mode in commit
2d36097, but I forgot to document it.  Add PACKET_FANOUT_QM as an available mode
in the af_packet documentation.  Applies to net-next.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Daniel Borkmann <dborkman@redhat.com>
---
 Documentation/networking/packet_mmap.txt | 1 +
 1 file changed, 1 insertion(+)

diff --git a/Documentation/networking/packet_mmap.txt b/Documentation/networking/packet_mmap.txt
index 91ffe1d..1404674 100644
--- a/Documentation/networking/packet_mmap.txt
+++ b/Documentation/networking/packet_mmap.txt
@@ -583,6 +583,7 @@ Currently implemented fanout policies are:
   - PACKET_FANOUT_CPU: schedule to socket by CPU packet arrives on
   - PACKET_FANOUT_RND: schedule to socket by random selection
   - PACKET_FANOUT_ROLLOVER: if one socket is full, rollover to another
+  - PACKET_FANOUT_QM: schedule to socket by skbs recorded queue_mapping
 
 Minimal example code by David S. Miller (try things like "./test eth0 hash",
 "./test eth0 lb", etc.):
-- 
1.8.3.1
