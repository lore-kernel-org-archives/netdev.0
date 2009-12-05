From: Emese Revfy <re.emese@gmail.com>
Subject: Re: [PATCH 22/31] Constify struct neigh_ops for 2.6.32 v1
Date: Sat, 05 Dec 2009 01:02:55 +0100
Message-ID: <4B19A32F.5020207@gmail.com>
References: <4B198670.2000406@gmail.com> <4B198FA1.7090807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932617AbZLEABB@vger.kernel.org>
In-Reply-To: <4B198FA1.7090807@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Emese Revfy <re.emese@gmail.com>

Constify struct neigh_ops.
Per Dave Miller's suggestion, resend with proper CC list and patch format.

Signed-off-by: Emese Revfy <re.emese@gmail.com>
---
 include/net/neighbour.h |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 3817fda..2c61d38 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -125,12 +125,12 @@ struct neighbour
 struct neigh_ops
 {
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
 
 struct pneigh_entry
