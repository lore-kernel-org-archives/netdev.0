From: re.emese@gmail.com
Subject: [PATCH 1/1] Constify struct neigh_ops for 2.6.32-git-053fe57ac v2
Date: Mon, 14 Dec 2009 01:00:15 +0100
Message-ID: <b6a0951139abdcfa2ab65e4da0423e2d0e0ae13d.1260663002.git.re.emese@gmail.com>
References: <cover.1260663002.git.re.emese@gmail.com>
Cc: Emese Revfy <re.emese@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@vyatta.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:34464 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754951AbZLMX6Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2009 18:58:25 -0500
In-Reply-To: <cover.1260663002.git.re.emese@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emese Revfy <re.emese@gmail.com>


Signed-off-by: Emese Revfy <re.emese@gmail.com>
---
 include/net/neighbour.h |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 0302f31..ac37ed6 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -121,12 +121,12 @@ struct neighbour {
 
 struct neigh_ops {
 	int			family;
-	void			(*solicit)(struct neighbour *, struct sk_buff*);
-	void			(*error_report)(struct neighbour *, struct sk_buff*);
-	int			(*output)(struct sk_buff*);
-	int			(*connected_output)(struct sk_buff*);
-	int			(*hh_output)(struct sk_buff*);
-	int			(*queue_xmit)(struct sk_buff*);
+	void			(* const solicit)(struct neighbour *, struct sk_buff*);
+	void			(* const error_report)(struct neighbour *, struct sk_buff*);
+	int			(* const output)(struct sk_buff*);
+	int			(* const connected_output)(struct sk_buff*);
+	int			(* const hh_output)(struct sk_buff*);
+	int			(* const queue_xmit)(struct sk_buff*);
 };
 
 struct pneigh_entry {
-- 
1.6.5.3

