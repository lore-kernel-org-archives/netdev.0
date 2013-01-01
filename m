From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next 3/3] netconsole: add IPv6 example in doc
Date: Tue,  1 Jan 2013 16:01:28 +0800
Message-ID: <1357027288-28675-3-git-send-email-amwang@redhat.com>
References: <1357027288-28675-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45449 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752024Ab3AAIBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jan 2013 03:01:50 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r0181o8f004756
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 1 Jan 2013 03:01:50 -0500
In-Reply-To: <1357027288-28675-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Update the netconsole document as well.

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
