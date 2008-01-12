From: "=?utf-8?q?Ilpo_J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/2] [HTB]: htb_classid is dead static inline
Date: Sat, 12 Jan 2008 13:53:36 +0200
Message-ID: <12001388163255-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1200138816244-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45961 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759495AbYALLxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 06:53:38 -0500
In-Reply-To: <1200138816244-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/sched/sch_htb.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 72beb66..6a2352c 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -214,10 +214,6 @@ static inline struct htb_class *htb_find(u32 handl=
e, struct Qdisc *sch)
  * then finish and return direct queue.
  */
 #define HTB_DIRECT (struct htb_class*)-1
-static inline u32 htb_classid(struct htb_class *cl)
-{
-	return (cl && cl !=3D HTB_DIRECT) ? cl->classid : TC_H_UNSPEC;
-}
=20
 static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdis=
c *sch,
 				      int *qerr)
--=20
1.5.0.6

