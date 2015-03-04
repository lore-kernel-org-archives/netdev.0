From: kbuild test robot <fengguang.wu@intel.com>
Subject: [PATCH jtkirshe-net-next] mpls: rtm_mpls_policy[] can be static
Date: Thu, 5 Mar 2015 05:33:54 +0800
Message-ID: <20150304213354.GA121629@lkp-sb04.lkp.intel.com>
References: <201503050540.GRC4YbDo%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201503050540.GRC4YbDo%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 af_mpls.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index b4d7cec..ee9a4b6 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -212,7 +212,7 @@ static struct packet_type mpls_packet_type __read_mostly = {
 	.func = mpls_forward,
 };
 
-const struct nla_policy rtm_mpls_policy[RTA_MAX+1] = {
+static const struct nla_policy rtm_mpls_policy[RTA_MAX+1] = {
 	[RTA_DST]		= { .type = NLA_U32 },
 	[RTA_OIF]		= { .type = NLA_U32 },
 };
