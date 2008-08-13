From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] tipc: Use the appropriate swab helper rather than an
	internal helper
Date: Tue, 12 Aug 2008 21:05:47 -0700
Message-ID: <1218600348.30194.105.camel@brick>
References: <1218587234.30194.93.camel@brick>
	 <20080812205422.4273d598.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	per.liden@ericsson.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:15669 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbYHMEFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 00:05:48 -0400
Received: by wf-out-1314.google.com with SMTP id 27so5249786wfd.4
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 21:05:47 -0700 (PDT)
In-Reply-To: <20080812205422.4273d598.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

___generally means I am an internal implementation detail, don't use
me.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Sorry for breaking the build Andrew, my testing has been with all the __constant
versions in-tree removed.

 net/tipc/subscr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 0326d30..f5da05d 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -85,7 +85,7 @@ static struct top_srv topsrv = { 0 };
 
 static u32 htohl(u32 in, int swap)
 {
-	return swap ? (u32)___constant_swab32(in) : in;
+	return swap ? (u32)swab32(in) : in;
 }
 
 /**
-- 
1.6.0.rc2.233.g3cb9d



