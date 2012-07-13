From: Ioan Orghici <ioanorghici@gmail.com>
Subject: [PATCH] sctp: fix sparse warning for sctp_init_cause_fixed
Date: Fri, 13 Jul 2012 20:16:37 +0300
Message-ID: <1342199797-11305-1-git-send-email-ioanorghici@gmail.com>
Cc: Ioan Orghici <ioanorghici@gmail.com>
To: vyasevich@gmail.com, sri@us.ibm.com, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:64517 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932301Ab2GMRQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 13:16:52 -0400
Received: by weyx8 with SMTP id x8so2630080wey.19
        for <netdev@vger.kernel.org>; Fri, 13 Jul 2012 10:16:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following sparse warning:
	* symbol 'sctp_init_cause_fixed' was not declared. Should it be
	  static?

Signed-off-by: Ioan Orghici <ioanorghici@gmail.com>
---
 net/sctp/sm_make_chunk.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index b6de71e..479a70e 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -132,7 +132,7 @@ void  sctp_init_cause(struct sctp_chunk *chunk, __be16 cause_code,
  * abort chunk.  Differs from sctp_init_cause in that it won't oops
  * if there isn't enough space in the op error chunk
  */
-int sctp_init_cause_fixed(struct sctp_chunk *chunk, __be16 cause_code,
+static int sctp_init_cause_fixed(struct sctp_chunk *chunk, __be16 cause_code,
 		      size_t paylen)
 {
 	sctp_errhdr_t err;
-- 
1.7.6.3
