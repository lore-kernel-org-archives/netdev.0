From: Joe Perches <joe@perches.com>
Subject: [PATCH] net/sctp/: Spelling fixes
Date: Mon, 17 Dec 2007 11:40:37 -0800
Message-ID: <1197920439-5455-31-git-send-email-joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3244 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933468AbXLQTlf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 14:41:35 -0500
Message-Id: <5703e57f925f31fc0eb38873bd7f10fc44f99cb4.1197918894.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sctp/sm_make_chunk.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index f487629..ed7c9e3 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -286,7 +286,7 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 
 	sctp_addto_chunk(retval, sizeof(ecap_param), &ecap_param);
 
-	/* Add the supported extensions paramter.  Be nice and add this
+	/* Add the supported extensions parameter.  Be nice and add this
 	 * fist before addiding the parameters for the extensions themselves
 	 */
 	if (num_ext) {
@@ -2859,7 +2859,7 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
 	chunk_len -= length;
 
 	/* Skip the address parameter and store a pointer to the first
-	 * asconf paramter.
+	 * asconf parameter.
 	 */
 	length = ntohs(addr_param->v4.param_hdr.length);
 	asconf_param = (sctp_addip_param_t *)((void *)addr_param + length);
@@ -2868,7 +2868,7 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
 	/* create an ASCONF_ACK chunk.
 	 * Based on the definitions of parameters, we know that the size of
 	 * ASCONF_ACK parameters are less than or equal to the twice of ASCONF
-	 * paramters.
+	 * parameters.
 	 */
 	asconf_ack = sctp_make_asconf_ack(asoc, serial, chunk_len * 2);
 	if (!asconf_ack)
@@ -3062,7 +3062,7 @@ int sctp_process_asconf_ack(struct sctp_association *asoc,
 	asconf_len -= length;
 
 	/* Skip the address parameter in the last asconf sent and store a
-	 * pointer to the first asconf paramter.
+	 * pointer to the first asconf parameter.
 	 */
 	length = ntohs(addr_param->v4.param_hdr.length);
 	asconf_param = (sctp_addip_param_t *)((void *)addr_param + length);
-- 
1.5.3.7.949.g2221a6

