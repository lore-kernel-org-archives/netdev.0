From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv6 net-next 1/6] sctp: drop unnecessary __packed from some stream reconf structures
Date: Thu,  9 Feb 2017 01:18:15 +0800
Message-ID: <5f2d5aa54716217f68f724e4165289bd964b8755.1486573728.git.lucien.xin@gmail.com>
References: <cover.1486573727.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36161 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753541AbdBHRUL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 12:20:11 -0500
In-Reply-To: <cover.1486573727.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1486573727.git.lucien.xin@gmail.com>
References: <cover.1486573727.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 85c727b59483 ("sctp: drop __packed from almost all SCTP structures")
has removed __packed from almost all SCTP structures. But there still are
three structures where it should be dropped.

This patch is to remove it from some stream reconf structures.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 2408c68..d74fca3 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -721,7 +721,7 @@ struct sctp_infox {
 struct sctp_reconf_chunk {
 	sctp_chunkhdr_t chunk_hdr;
 	__u8 params[0];
-} __packed;
+};
 
 struct sctp_strreset_outreq {
 	sctp_paramhdr_t param_hdr;
@@ -729,12 +729,12 @@ struct sctp_strreset_outreq {
 	__u32 response_seq;
 	__u32 send_reset_at_tsn;
 	__u16 list_of_streams[0];
-} __packed;
+};
 
 struct sctp_strreset_inreq {
 	sctp_paramhdr_t param_hdr;
 	__u32 request_seq;
 	__u16 list_of_streams[0];
-} __packed;
+};
 
 #endif /* __LINUX_SCTP_H__ */
-- 
2.1.0
