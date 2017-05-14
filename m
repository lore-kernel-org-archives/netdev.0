From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2 master 1/4] pedit: Fix a typo in warning
Date: Sun, 14 May 2017 11:17:43 +0300
Message-ID: <20170514081746.9010-2-amir@vadai.me>
References: <20170514081746.9010-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amir@vadai.me>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34742 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751047AbdENIRs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 14 May 2017 04:17:48 -0400
Received: by mail-wm0-f68.google.com with SMTP id d127so21297636wmf.1
        for <netdev@vger.kernel.org>; Sun, 14 May 2017 01:17:47 -0700 (PDT)
In-Reply-To: <20170514081746.9010-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'ex' attribute should be placed after 'action pedit' and not after
'munge'.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 tc/m_pedit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index 6498dd91b471..7ef2acc52bce 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -146,7 +146,7 @@ int pack_key(struct m_pedit_sel *_sel, struct m_pedit_key *tkey)
 		if (tkey->htype != TCA_PEDIT_KEY_EX_HDR_TYPE_NETWORK ||
 		    tkey->cmd != TCA_PEDIT_KEY_EX_CMD_SET) {
 			fprintf(stderr,
-				"Munge parameters not supported. Use 'munge ex'.\n");
+				"Munge parameters not supported. Use 'pedit ex munge ...'.\n");
 			return -1;
 		}
 	}
-- 
2.12.2
