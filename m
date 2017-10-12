From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 07/10] staging/irda/net: Delete an unnecessary variable
 initialisation in four functions
Date: Thu, 12 Oct 2017 12:47:05 +0200
Message-ID: <db761c03-3e90-4284-2652-a5516b372a32@users.sourceforge.net>
References: <8152401b-d68d-c4fe-2619-82a09e0c52ec@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
        Al Viro <viro@zeniv.linux.org.uk>,
        Corentin Labbe <clabbe.montjoie@gmail.com>,
        David Howells <dhowells@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Georgiana Chelu <georgiana.chelu93@gmail.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Julia Lawall <julia.lawall@lip6.fr>,
        Samuel Ortiz <samuel@sortiz.org>,
        Srishti Sharma <srishtishar@gmail.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Yuan Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8152401b-d68d-c4fe-2619-82a09e0c52ec@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Wed, 11 Oct 2017 22:26:00 +0200

The variable "tx_skb" will eventually be set to an appropriate pointer
a bit later. Thus omit the explicit initialisation at the beginning.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/irda/net/irlap_frame.c | 6 +++---
 drivers/staging/irda/net/irttp.c       | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/irda/net/irlap_frame.c b/drivers/staging/irda/net/irlap_frame.c
index 25ceb06efd58..16fe7f53fdb7 100644
--- a/drivers/staging/irda/net/irlap_frame.c
+++ b/drivers/staging/irda/net/irlap_frame.c
@@ -258,7 +258,7 @@ void irlap_send_ua_response_frame(struct irlap_cb *self, struct qos_info *qos)
  */
 void irlap_send_dm_frame( struct irlap_cb *self)
 {
-	struct sk_buff *tx_skb = NULL;
+	struct sk_buff *tx_skb;
 	struct dm_frame *frame;
 
 	IRDA_ASSERT(self, return;);
@@ -288,7 +288,7 @@ void irlap_send_dm_frame( struct irlap_cb *self)
  */
 void irlap_send_disc_frame(struct irlap_cb *self)
 {
-	struct sk_buff *tx_skb = NULL;
+	struct sk_buff *tx_skb;
 	struct disc_frame *frame;
 
 	IRDA_ASSERT(self, return;);
@@ -315,7 +315,7 @@ void irlap_send_disc_frame(struct irlap_cb *self)
 void irlap_send_discovery_xid_frame(struct irlap_cb *self, int S, __u8 s,
 				    __u8 command, discovery_t *discovery)
 {
-	struct sk_buff *tx_skb = NULL;
+	struct sk_buff *tx_skb;
 	struct xid_frame *frame;
 	__u32 bcast = BROADCAST;
 	__u8 *info;
diff --git a/drivers/staging/irda/net/irttp.c b/drivers/staging/irda/net/irttp.c
index 2adba87aeb68..bc612227cdc3 100644
--- a/drivers/staging/irda/net/irttp.c
+++ b/drivers/staging/irda/net/irttp.c
@@ -811,7 +811,7 @@ static void irttp_run_tx_queue(struct tsap_cb *self)
  */
 static inline void irttp_give_credit(struct tsap_cb *self)
 {
-	struct sk_buff *tx_skb = NULL;
+	struct sk_buff *tx_skb;
 	unsigned long flags;
 	int n;
 
-- 
2.14.2
