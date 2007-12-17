From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 5/5] [DCCP]: Remove unused inline function
Date: Mon, 17 Dec 2007 13:00:19 -0200
Message-ID: <1197903619-12301-6-git-send-email-acme@redhat.com>
References: <1197903619-12301-1-git-send-email-acme@redhat.com>
 <1197903619-12301-2-git-send-email-acme@redhat.com>
 <1197903619-12301-3-git-send-email-acme@redhat.com>
 <1197903619-12301-4-git-send-email-acme@redhat.com>
 <1197903619-12301-5-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Ian McDonald <ian.mcdonald@jandi.co.nz>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.182]:53098 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757557AbXLQPAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 10:00:34 -0500
Received: by el-out-1112.google.com with SMTP id v27so296017ele.23
        for <netdev@vger.kernel.org>; Mon, 17 Dec 2007 07:00:33 -0800 (PST)
In-Reply-To: <1197903619-12301-5-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

The function follows48(), which is a special-case of dccp_delta_seqno(),
is nowhere used in the DCCP code, thus removed by this patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/dccp.h |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index b138e20..ebe59d9 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -153,12 +153,6 @@ static inline u64 max48(const u64 seq1, const u64 seq2)
 	return after48(seq1, seq2) ? seq1 : seq2;
 }
 
-/* is seq1 next seqno after seq2 */
-static inline int follows48(const u64 seq1, const u64 seq2)
-{
-	return dccp_delta_seqno(seq2, seq1) == 1;
-}
-
 enum {
 	DCCP_MIB_NUM = 0,
 	DCCP_MIB_ACTIVEOPENS,			/* ActiveOpens */
-- 
1.5.3.6

