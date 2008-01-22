From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 5/12 net-2.6.25] [NETNS]: Re-export init_net via EXPORT_SYMBOL.
Date: Tue, 22 Jan 2008 18:59:22 +0300
Message-ID: <1201017566-16985-5-git-send-email-den@openvz.org>
References: <479612BE.8030409@openvz.org>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:64406 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752789AbYAVP7Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 10:59:24 -0500
In-Reply-To: <479612BE.8030409@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

init_net is used added as a parameter to a lot of old API calls, f.e.
ip_dev_find. These calls were exported as EXPORT_SYMBOL. So, export init_net
as EXPORT_SYMBOL to keep networking API consistent.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/core/net_namespace.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 8023208..26e941d 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -18,7 +18,7 @@ static DEFINE_MUTEX(net_mutex);
 LIST_HEAD(net_namespace_list);
 
 struct net init_net;
-EXPORT_SYMBOL_GPL(init_net);
+EXPORT_SYMBOL(init_net);
 
 /*
  * setup_net runs the initializers for the network namespace object.
-- 
1.5.3.rc5

