From: weiyj_lk@163.com
Subject: [PATCH -next] netns: remove duplicated include from net_namespace.c
Date: Thu, 16 Apr 2015 21:17:35 +0800
Message-ID: <1429190255-24722-1-git-send-email-weiyj_lk@163.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	xiao jin <jin.xiao@intel.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-12.163.com ([220.181.12.12]:57883 "EHLO m12-12.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754692AbbDPNVC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2015 09:21:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove duplicated include.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/core/net_namespace.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index e5e96b0..9c43cf6 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -16,7 +16,6 @@
 #include <linux/export.h>
 #include <linux/user_namespace.h>
 #include <linux/net_namespace.h>
-#include <linux/rtnetlink.h>
 #include <net/sock.h>
 #include <net/netlink.h>
 #include <net/net_namespace.h>
