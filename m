From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 1/2] socket: add documentation for missing elements
Date: Wed, 12 Jul 2017 09:29:06 -0700
Message-ID: <20170712162907.18465-2-sthemmin@microsoft.com>
References: <20170712162907.18465-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36523 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753509AbdGLQ3S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 12:29:18 -0400
Received: by mail-pf0-f181.google.com with SMTP id q86so15421679pfl.3
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2017 09:29:17 -0700 (PDT)
In-Reply-To: <20170712162907.18465-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fill in missing kernel-doc for missing elements in struct sock.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 include/net/sock.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index 8c85791fc196..f69c8c2782df 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -246,6 +246,7 @@ struct sock_common {
   *	@sk_policy: flow policy
   *	@sk_receive_queue: incoming packets
   *	@sk_wmem_alloc: transmit queue bytes committed
+  *	@sk_tsq_flags: TCP Small Queues flags
   *	@sk_write_queue: Packet sending queue
   *	@sk_omem_alloc: "o" is "option" or "other"
   *	@sk_wmem_queued: persistent queue size
@@ -257,6 +258,7 @@ struct sock_common {
   *	@sk_pacing_status: Pacing status (requested, handled by sch_fq)
   *	@sk_max_pacing_rate: Maximum pacing rate (%SO_MAX_PACING_RATE)
   *	@sk_sndbuf: size of send buffer in bytes
+  *	@__sk_flags_offset: empty field used to determine location of bitfield
   *	@sk_padding: unused element for alignment
   *	@sk_no_check_tx: %SO_NO_CHECK setting, set checksum in TX packets
   *	@sk_no_check_rx: allow zero checksum in RX packets
@@ -277,6 +279,7 @@ struct sock_common {
   *	@sk_drops: raw/udp drops counter
   *	@sk_ack_backlog: current listen backlog
   *	@sk_max_ack_backlog: listen backlog set in listen()
+  *	@sk_uid: user id of owner
   *	@sk_priority: %SO_PRIORITY setting
   *	@sk_type: socket type (%SOCK_STREAM, etc)
   *	@sk_protocol: which protocol this socket belongs in this network family
-- 
2.11.0
