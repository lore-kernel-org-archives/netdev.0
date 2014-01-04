From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/2] tipc: make local function static
Date: Sat, 4 Jan 2014 13:47:48 -0800
Message-ID: <20140104134748.0ddff391@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jon Maloy <jon.maloy@ericsson.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:46756 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739AbaADW2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 17:28:10 -0500
Received: by mail-pb0-f41.google.com with SMTP id jt11so16979113pbb.14
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 14:28:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 net/tipc/link.c |    2 +-
 net/tipc/link.h |    1 -
 2 files changed, 1 insertion(+), 2 deletions(-)

--- a/net/tipc/link.c	2014-01-04 13:39:54.308221241 -0800
+++ b/net/tipc/link.c	2014-01-04 13:42:25.189725016 -0800
@@ -1169,7 +1169,7 @@ reject:
 /*
  * tipc_link_push_packet: Push one unsent packet to the media
  */
-u32 tipc_link_push_packet(struct tipc_link *l_ptr)
+static u32 tipc_link_push_packet(struct tipc_link *l_ptr)
 {
 	struct sk_buff *buf = l_ptr->first_out;
 	u32 r_q_size = l_ptr->retransm_queue_size;
--- a/net/tipc/link.h	2014-01-04 13:39:54.308221241 -0800
+++ b/net/tipc/link.h	2014-01-04 13:42:25.189725016 -0800
@@ -221,7 +221,6 @@ void tipc_link_send_duplicate(struct tip
 void tipc_link_reset_fragments(struct tipc_link *l_ptr);
 int tipc_link_is_up(struct tipc_link *l_ptr);
 int tipc_link_is_active(struct tipc_link *l_ptr);
-u32 tipc_link_push_packet(struct tipc_link *l_ptr);
 void tipc_link_stop(struct tipc_link *l_ptr);
 struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area, int req_tlv_space, u16 cmd);
 struct sk_buff *tipc_link_cmd_show_stats(const void *req_tlv_area, int req_tlv_space);
