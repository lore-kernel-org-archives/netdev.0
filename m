From: kan.liang@intel.com
Subject: [RFC PATCH 06/30] net/netpolicy: get CPU information
Date: Sun, 17 Jul 2016 23:56:00 -0700
Message-ID: <1468824984-65318-7-git-send-email-kan.liang@intel.com>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
	peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, jesse.brandeburg@intel.com,
	andi@firstfloor.org, Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
