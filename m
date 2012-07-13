From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] tc-bfifo: man: Add parameter value range.
Date: Fri, 13 Jul 2012 15:08:00 +0800
Message-ID: <4FFFC950.6020806@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59109 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753666Ab2GMHIn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2012 03:08:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add value range for 'limit' parameter.
---
 man/man8/tc-bfifo.8 |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/man/man8/tc-bfifo.8 b/man/man8/tc-bfifo.8
index 8dda4bb..417e45c 100644
--- a/man/man8/tc-bfifo.8
+++ b/man/man8/tc-bfifo.8
@@ -40,8 +40,12 @@ to the interface txqueuelen, as specified with
 .BR ifconfig (8)
 or
 .BR ip (8).
+The range for this parameter is [0, UINT32_MAX].
 
 For bfifo, it defaults to the txqueuelen multiplied by the interface MTU.
+The range for this parameter is [0, UINT32_MAX] bytes.
+
+Note: The link layer header was considered when couting packets length.
 
 .SH OUTPUT
 The output of 
-- 
1.7.1
