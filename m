From: Shan Wei <shanwei88@gmail.com>
Subject: [PATCH net-next ] net: doc: fix many typos in scaling.txt
Date: Tue, 20 Dec 2011 10:34:15 +0800
Message-ID: <4EEFF427.1090801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?5Y2V5Y2r?= <shanwei88@gmail.com>,
	NetDev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:46359 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab1LTCb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 21:31:57 -0500
Received: by iaeh11 with SMTP id h11so9483448iae.19
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 18:31:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix some trivial typos.

Signed-off-by: Shan Wei <shanwei88@gmail.com>
---
 Documentation/networking/scaling.txt |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/scaling.txt b/Documentation/networking/scaling.txt
index a177de2..579994a 100644
--- a/Documentation/networking/scaling.txt
+++ b/Documentation/networking/scaling.txt
@@ -208,7 +208,7 @@ The counter in rps_dev_flow_table values records the length of the current
 CPU's backlog when a packet in this flow was last enqueued. Each backlog
 queue has a head counter that is incremented on dequeue. A tail counter
 is computed as head counter + queue length. In other words, the counter
-in rps_dev_flow_table[i] records the last element in flow i that has
+in rps_dev_flow[i] records the last element in flow i that has
 been enqueued onto the currently designated CPU for flow i (of course,
 entry i is actually selected by hash and multiple flows may hash to the
 same entry i).
@@ -224,7 +224,7 @@ following is true:

 - The current CPU's queue head counter >= the recorded tail counter
   value in rps_dev_flow[i]
-- The current CPU is unset (equal to NR_CPUS)
+- The current CPU is unset (equal to RPS_NO_CPU)
 - The current CPU is offline

 After this check, the packet is sent to the (possibly updated) current
@@ -235,7 +235,7 @@ CPU.

 ==== RFS Configuration

-RFS is only available if the kconfig symbol CONFIG_RFS is enabled (on
+RFS is only available if the kconfig symbol CONFIG_RPS is enabled (on
 by default for SMP). The functionality remains disabled until explicitly
 configured. The number of entries in the global flow table is set through:

@@ -258,7 +258,7 @@ For a single queue device, the rps_flow_cnt value for the single queue
 would normally be configured to the same value as rps_sock_flow_entries.
 For a multi-queue device, the rps_flow_cnt for each queue might be
 configured as rps_sock_flow_entries / N, where N is the number of
-queues. So for instance, if rps_flow_entries is set to 32768 and there
+queues. So for instance, if rps_sock_flow_entries is set to 32768 and there
 are 16 configured receive queues, rps_flow_cnt for each queue might be
 configured as 2048.

-- 
1.7.1
