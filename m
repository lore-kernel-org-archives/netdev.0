From: David Miller <davem@davemloft.net>
Subject: [PATCH 01/20] xfrm: Mark flowi arg const in key extraction helpers.
Date: Tue, 22 Feb 2011 19:54:08 -0800 (PST)
Message-ID: <20110222.195408.226797395.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32815
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755683Ab1BWDxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:53:31 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A44F424C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:54:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 1f6e8a0..2de3dae 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -790,7 +790,7 @@ static __inline__ int addr_match(void *token1, void *token2, int prefixlen)
 }
 
 static __inline__
-__be16 xfrm_flowi_sport(struct flowi *fl)
+__be16 xfrm_flowi_sport(const struct flowi *fl)
 {
 	__be16 port;
 	switch(fl->proto) {
@@ -817,7 +817,7 @@ __be16 xfrm_flowi_sport(struct flowi *fl)
 }
 
 static __inline__
-__be16 xfrm_flowi_dport(struct flowi *fl)
+__be16 xfrm_flowi_dport(const struct flowi *fl)
 {
 	__be16 port;
 	switch(fl->proto) {
@@ -1127,7 +1127,7 @@ static inline int xfrm6_policy_check_reverse(struct sock *sk, int dir,
 #endif
 
 static __inline__
-xfrm_address_t *xfrm_flowi_daddr(struct flowi *fl, unsigned short family)
+xfrm_address_t *xfrm_flowi_daddr(const struct flowi *fl, unsigned short family)
 {
 	switch (family){
 	case AF_INET:
@@ -1139,7 +1139,7 @@ xfrm_address_t *xfrm_flowi_daddr(struct flowi *fl, unsigned short family)
 }
 
 static __inline__
-xfrm_address_t *xfrm_flowi_saddr(struct flowi *fl, unsigned short family)
+xfrm_address_t *xfrm_flowi_saddr(const struct flowi *fl, unsigned short family)
 {
 	switch (family){
 	case AF_INET:
@@ -1151,7 +1151,7 @@ xfrm_address_t *xfrm_flowi_saddr(struct flowi *fl, unsigned short family)
 }
 
 static __inline__
-void xfrm_flowi_addr_get(struct flowi *fl,
+void xfrm_flowi_addr_get(const struct flowi *fl,
 			 xfrm_address_t *saddr, xfrm_address_t *daddr,
 			 unsigned short family)
 {
@@ -1204,7 +1204,7 @@ xfrm_state_addr_check(struct xfrm_state *x,
 }
 
 static __inline__ int
-xfrm_state_addr_flow_check(struct xfrm_state *x, struct flowi *fl,
+xfrm_state_addr_flow_check(struct xfrm_state *x, const struct flowi *fl,
 			   unsigned short family)
 {
 	switch (family) {
-- 
1.7.4.1

