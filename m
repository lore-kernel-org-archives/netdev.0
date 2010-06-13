From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 1/8] scm: Reorder scm_cookie.
Date: Sun, 13 Jun 2010 06:27:04 -0700
Message-ID: <m1d3vvhxlj.fsf@fess.ebiederm.org>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Serge Hallyn <serue@us.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	<netdev@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:39684 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528Ab0FMN1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 09:27:09 -0400
In-Reply-To: <m1hbl7hxo3.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Sun\, 13 Jun 2010 06\:25\:32 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Reorder the fields in scm_cookie so they pack better on 64bit.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/scm.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/scm.h b/include/net/scm.h
index 8360e47..17d9d2e 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -19,8 +19,8 @@ struct scm_fp_list {
 };
 
 struct scm_cookie {
-	struct ucred		creds;		/* Skb credentials	*/
 	struct scm_fp_list	*fp;		/* Passed files		*/
+	struct ucred		creds;		/* Skb credentials	*/
 #ifdef CONFIG_SECURITY_NETWORK
 	u32			secid;		/* Passed security ID 	*/
 #endif
-- 
1.6.5.2.143.g8cc62

