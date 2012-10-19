From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 17/21] infiniband: Convert ipv4_is_<foo> uses to ipv4_addr_<foo>
Date: Thu, 18 Oct 2012 21:15:01 -0700
Message-ID: <a7ac057bbe9925082d641fdeaece9b94ac307609.1350618012.git.joe@perches.com>
References: <cover.1350618006.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1350618006.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the new ipv4_addr_<foo> functions to be consistent with
the ipv6_addr_<foo> and eth_addr_<foo> style.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/infiniband/core/cma.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index a7568c3..108f96f 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -683,7 +683,7 @@ static inline int cma_zero_addr(struct sockaddr *addr)
 	struct in6_addr *ip6;
 
 	if (addr->sa_family == AF_INET)
-		return ipv4_is_zeronet(
+		return ipv4_addr_zeronet(
 			((struct sockaddr_in *)addr)->sin_addr.s_addr);
 	else {
 		ip6 = &((struct sockaddr_in6 *) addr)->sin6_addr;
@@ -695,7 +695,7 @@ static inline int cma_zero_addr(struct sockaddr *addr)
 static inline int cma_loopback_addr(struct sockaddr *addr)
 {
 	if (addr->sa_family == AF_INET)
-		return ipv4_is_loopback(
+		return ipv4_addr_loopback(
 			((struct sockaddr_in *) addr)->sin_addr.s_addr);
 	else
 		return ipv6_addr_loopback(
-- 
1.7.8.111.gad25c.dirty
