From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 09/13] Create a tproxy flag in struct sk_buff
Date: Mon, 05 Mar 2007 16:46:21 +0100
Message-ID: <20070305154621.3471.87479.stgit@nienna.balabit>
References: <20070305154451.3471.18396.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:4851 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933538AbXCEPqX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 10:46:23 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 40E46294020
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2007 16:46:22 +0100 (CET)
In-Reply-To: <20070305154451.3471.18396.stgit@nienna.balabit>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We would like to be able to match on whether or not a given packet has
been diverted by tproxy. To make this possible we need a flag in
sk_buff.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---

 include/linux/skbuff.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4ff3940..6d7f5c7 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -284,7 +284,8 @@ struct sk_buff {
 				nfctinfo:3;
 	__u8			pkt_type:3,
 				fclone:2,
-				ipvs_property:1;
+				ipvs_property:1,
+				ip_tproxy:1;
 	__be16			protocol;
 
 	void			(*destructor)(struct sk_buff *skb);

