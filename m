From: kan.liang@intel.com
Subject: [RFC V2 PATCH 04/25] net/netpolicy: get CPU information
Date: Thu,  4 Aug 2016 15:36:08 -0400
Message-ID: <1470339389-8542-5-git-send-email-kan.liang@intel.com>
References: <1470339389-8542-1-git-send-email-kan.liang@intel.com>
Cc: mingo@redhat.com, peterz@infradead.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
	daniel@iogearbox.net, tom@herbertland.com, rdunlap@infradead.org,
	xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
	jesse.brandeburg@intel.com, andi@firstfloor.org,
	Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:38363 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965384AbcHDTgq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 15:36:46 -0400
In-Reply-To: <1470339389-8542-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

Net policy also needs to know CPU information. Currently, online
CPU number is enough.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 net/core/netpolicy.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 7c34c8a..075aaca 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -49,6 +49,11 @@ static void netpolicy_free_dev_info(struct netpolicy_dev_info *d_info)
 	kfree(d_info->tx_irq);
 }
 
+static u32 netpolicy_get_cpu_information(void)
+{
+	return num_online_cpus();
+}
+
 const char *policy_name[NET_POLICY_MAX] = {
 	"NONE"
 };
-- 
2.5.5
