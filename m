From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next] sctp: remove unused var from sctp_process_asconf
Date: Fri, 13 Jan 2017 18:27:33 -0200
Message-ID: <5da2cda90a7489b22ae98703d7543c5316bae375.1484336552.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:33357 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751116AbdAMU21 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 15:28:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Assigned but not used.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/sm_make_chunk.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index a15d824a313d310ed03ba77055d22b1c7c9d0662..80a9088084ac0d1116bf983fad9a0cdfddeefe44 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3210,7 +3210,6 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
 	union sctp_params param;
 	sctp_addiphdr_t		*hdr;
 	union sctp_addr_param	*addr_param;
-	sctp_addip_param_t	*asconf_param;
 	struct sctp_chunk	*asconf_ack;
 	__be16	err_code;
 	int	length = 0;
@@ -3230,7 +3229,6 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
 	 * asconf parameter.
 	 */
 	length = ntohs(addr_param->p.length);
-	asconf_param = (void *)addr_param + length;
 	chunk_len -= length;
 
 	/* create an ASCONF_ACK chunk.
-- 
2.9.3
