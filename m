From: kan.liang@intel.com
Subject: [RFC V3 PATCH 04/26] net/netpolicy: get CPU information
Date: Mon, 12 Sep 2016 07:55:37 -0700
Message-ID: <1473692159-4017-5-git-send-email-kan.liang@intel.com>
References: <1473692159-4017-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
        peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        akpm@linux-foundation.org, keescook@chromium.org,
        viro@zeniv.linux.org.uk, gorcunov@openvz.org,
        john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
        decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
        daniel@iogearbox.net, tom@herbertland.com, rdunlap@infradead.org,
        xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
        stephen@networkplumber.org, alexei.starovoitov@gmail.com,
        jesse.brandeburg@intel.com, andi@firstfloor.org,
        Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473692159-4017-1-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kan Liang <kan.liang@intel.com>

Net policy also needs to know CPU information. Currently, online
CPU count is enough.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 net/core/netpolicy.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 882f0de..31c41ca 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -50,6 +50,11 @@ static void netpolicy_free_dev_info(struct netpolicy_dev_info *d_info)
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
