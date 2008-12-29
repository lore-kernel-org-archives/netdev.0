From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH 3/3] cls_cgroup: clean up Kconfig
Date: Mon, 29 Dec 2008 11:57:25 +0800
Message-ID: <49584AA5.9030509@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55310 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752479AbYL2D6b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Dec 2008 22:58:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cls_cgroup can't be compiled as a module, since it's not supported by
cgroup.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 net/sched/Kconfig |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 4f7ef0d..929218a 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -335,9 +335,6 @@ config NET_CLS_CGROUP
 	  Say Y here if you want to classify packets based on the control
 	  cgroup of their process.
 
-	  To compile this code as a module, choose M here: the
-	  module will be called cls_cgroup.
-
 config NET_EMATCH
 	bool "Extended Matches"
 	select NET_CLS
-- 
1.5.4.rc3

