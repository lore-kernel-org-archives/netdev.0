From: Joe Perches <joe@perches.com>
Subject: [PATCH] net/irda/: Spelling fixes
Date: Mon, 17 Dec 2007 11:40:33 -0800
Message-ID: <5703e57f925f31fc0eb38873bd7f10fc44f99cb4.1197918894.git.joe__23325.5484178246$1197922074$gmane$org@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S936813AbXLQUHO@vger.kernel.org>
Message-Id: <5703e57f925f31fc0eb38873bd7f10fc44f99cb4.1197918894.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 net/irda/ircomm/ircomm_param.c |    2 +-
 net/irda/irlan/irlan_eth.c     |    2 +-
 net/irda/irlap_frame.c         |    2 +-
 net/irda/parameters.c          |   12 ++++++------
 net/irda/wrapper.c             |    2 +-
 5 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/irda/ircomm/ircomm_param.c b/net/irda/ircomm/ircomm_param.c
index e5e4792..598dcbe 100644
--- a/net/irda/ircomm/ircomm_param.c
+++ b/net/irda/ircomm/ircomm_param.c
@@ -496,7 +496,7 @@ static int ircomm_param_poll(void *instance, irda_param_t *param, int get)
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return -1;);
 
-	/* Poll parameters are always of lenght 0 (just a signal) */
+	/* Poll parameters are always of length 0 (just a signal) */
 	if (!get) {
 		/* Respond with DTE line settings */
 		ircomm_param_request(self, IRCOMM_DTE, TRUE);
diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index c682207..1ab91f7 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -342,7 +342,7 @@ static void irlan_eth_set_multicast_list(struct net_device *dev)
 
 	if (dev->flags & IFF_PROMISC) {
 		/* Enable promiscuous mode */
-		IRDA_WARNING("Promiscous mode not implemented by IrLAN!\n");
+		IRDA_WARNING("Promiscuous mode not implemented by IrLAN!\n");
 	}
 	else if ((dev->flags & IFF_ALLMULTI) || dev->mc_count > HW_MAX_ADDRS) {
 		/* Disable promiscuous mode, use normal mode. */
diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index 4f37645..7c132d6 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -144,7 +144,7 @@ void irlap_send_snrm_frame(struct irlap_cb *self, struct qos_info *qos)
 	frame->control = SNRM_CMD | PF_BIT;
 
 	/*
-	 *  If we are establishing a connection then insert QoS paramerters
+	 *  If we are establishing a connection then insert QoS parameters
 	 */
 	if (qos) {
 		skb_put(tx_skb, 9); /* 25 left */
diff --git a/net/irda/parameters.c b/net/irda/parameters.c
index 2627dad..b23a3c7 100644
--- a/net/irda/parameters.c
+++ b/net/irda/parameters.c
@@ -133,7 +133,7 @@ static int irda_insert_integer(void *self, __u8 *buf, int len, __u8 pi,
 	int err;
 
 	p.pi = pi;             /* In case handler needs to know */
-	p.pl = type & PV_MASK; /* The integer type codes the lenght as well */
+	p.pl = type & PV_MASK; /* The integer type codes the length as well */
 	p.pv.i = 0;            /* Clear value */
 
 	/* Call handler for this parameter */
@@ -142,7 +142,7 @@ static int irda_insert_integer(void *self, __u8 *buf, int len, __u8 pi,
 		return err;
 
 	/*
-	 * If parameter lenght is still 0, then (1) this is an any length
+	 * If parameter length is still 0, then (1) this is an any length
 	 * integer, and (2) the handler function does not care which length
 	 * we choose to use, so we pick the one the gives the fewest bytes.
 	 */
@@ -206,11 +206,11 @@ static int irda_extract_integer(void *self, __u8 *buf, int len, __u8 pi,
 {
 	irda_param_t p;
 	int n = 0;
-	int extract_len;	/* Real lenght we extract */
+	int extract_len;	/* Real length we extract */
 	int err;
 
 	p.pi = pi;     /* In case handler needs to know */
-	p.pl = buf[1]; /* Extract lenght of value */
+	p.pl = buf[1]; /* Extract length of value */
 	p.pv.i = 0;    /* Clear value */
 	extract_len = p.pl;	/* Default : extract all */
 
@@ -297,7 +297,7 @@ static int irda_extract_string(void *self, __u8 *buf, int len, __u8 pi,
 	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
 
 	p.pi = pi;     /* In case handler needs to know */
-	p.pl = buf[1]; /* Extract lenght of value */
+	p.pl = buf[1]; /* Extract length of value */
 
 	IRDA_DEBUG(2, "%s(), pi=%#x, pl=%d\n", __FUNCTION__,
 		   p.pi, p.pl);
@@ -339,7 +339,7 @@ static int irda_extract_octseq(void *self, __u8 *buf, int len, __u8 pi,
 	irda_param_t p;
 
 	p.pi = pi;     /* In case handler needs to know */
-	p.pl = buf[1]; /* Extract lenght of value */
+	p.pl = buf[1]; /* Extract length of value */
 
 	/* Check if buffer is long enough for parsing */
 	if (len < (2+p.pl)) {
diff --git a/net/irda/wrapper.c b/net/irda/wrapper.c
index e712867..c246983 100644
--- a/net/irda/wrapper.c
+++ b/net/irda/wrapper.c
@@ -238,7 +238,7 @@ async_bump(struct net_device *dev,
 	skb_reserve(newskb, 1);
 
 	if(docopy) {
-		/* Copy data without CRC (lenght already checked) */
+		/* Copy data without CRC (length already checked) */
 		skb_copy_to_linear_data(newskb, rx_buff->data,
 					rx_buff->len - 2);
 		/* Deliver this skb */
-- 
1.5.3.7.949.g2221a6

