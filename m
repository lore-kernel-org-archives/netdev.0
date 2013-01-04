From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v3 3/3] netconsole: add IPv6 example in doc
Date: Fri,  4 Jan 2013 11:14:33 +0800
Message-ID: <1357269273-7575-4-git-send-email-amwang@redhat.com>
References: <1357269273-7575-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37559 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753682Ab3ADDPq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2013 22:15:46 -0500
In-Reply-To: <1357269273-7575-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Update the netconsole document as well.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 Documentation/networking/netconsole.txt |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/netconsole.txt b/Documentation/networking/netconsole.txt
index 2e9e0ae2..a5d574a 100644
--- a/Documentation/networking/netconsole.txt
+++ b/Documentation/networking/netconsole.txt
@@ -1,9 +1,10 @@
 
 started by Ingo Molnar <mingo@redhat.com>, 2001.09.17
 2.6 port and netpoll api by Matt Mackall <mpm@selenic.com>, Sep 9 2003
+IPv6 support by Cong Wang <xiyou.wangcong@gmail.com>, Jan 1 2013
 
 Please send bug reports to Matt Mackall <mpm@selenic.com>
-and Satyam Sharma <satyam.sharma@gmail.com>
+Satyam Sharma <satyam.sharma@gmail.com>, and Cong Wang <xiyou.wangcong@gmail.com>
 
 Introduction:
 =============
@@ -41,6 +42,10 @@ Examples:
 
  insmod netconsole netconsole=@/,@10.0.0.2/
 
+  or using IPv6
+
+ insmod netconsole netconsole=@/,@fd00:1:2:3::1/
+
 It also supports logging to multiple remote agents by specifying
 parameters for the multiple agents separated by semicolons and the
 complete string enclosed in "quotes", thusly:
-- 
1.7.7.6
