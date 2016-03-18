From: kbuild test robot <fengguang.wu@intel.com>
Subject: [RFC PATCH linux-next] net: dst_cache_per_cpu_dst_set() can be static
Date: Fri, 18 Mar 2016 23:27:28 +0800
Message-ID: <20160318152728.GA64259@cairo>
References: <201603182348.v699gI0M%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56663 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754343AbcCRP2s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2016 11:28:48 -0400
Content-Disposition: inline
In-Reply-To: <201603182348.v699gI0M%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 dst_cache.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/dst_cache.c b/net/core/dst_cache.c
index 3938f3f..554d364 100644
--- a/net/core/dst_cache.c
+++ b/net/core/dst_cache.c
@@ -28,8 +28,8 @@ struct dst_cache_pcpu {
 	};
 };
 
-void dst_cache_per_cpu_dst_set(struct dst_cache_pcpu *dst_cache,
-			       struct dst_entry *dst, u32 cookie)
+static void dst_cache_per_cpu_dst_set(struct dst_cache_pcpu *dst_cache,
+				      struct dst_entry *dst, u32 cookie)
 {
 	dst_release(dst_cache->dst);
 	if (dst)
@@ -39,8 +39,8 @@ void dst_cache_per_cpu_dst_set(struct dst_cache_pcpu *dst_cache,
 	dst_cache->dst = dst;
 }
 
-struct dst_entry *dst_cache_per_cpu_get(struct dst_cache *dst_cache,
-					struct dst_cache_pcpu *idst)
+static struct dst_entry *dst_cache_per_cpu_get(struct dst_cache *dst_cache,
+					       struct dst_cache_pcpu *idst)
 {
 	struct dst_entry *dst;
 
