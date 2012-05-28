From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH 2/2] tc-drr(8): tab unquoted in a argument to a macro
Date: Mon, 28 May 2012 13:46:05 +0200
Message-ID: <1338205565-11872-2-git-send-email-andreas@fatal.se>
References: <1338205565-11872-1-git-send-email-andreas@fatal.se>
Cc: netdev@vger.kernel.org, Bjarni Ingi Gislason <bjarniig@rhi.hi.is>,
	Andreas Henriksson <andreas@fatal.se>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b22.telenor.se ([195.54.99.213]:54726 "EHLO
	smtprelay-b22.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754054Ab2E1LnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2012 07:43:13 -0400
Received: from ipb5.telenor.se (ipb5.telenor.se [195.54.127.168])
	by smtprelay-b22.telenor.se (Postfix) with ESMTP id 5DF6814A95
	for <netdev@vger.kernel.org>; Mon, 28 May 2012 13:43:12 +0200 (CEST)
In-Reply-To: <1338205565-11872-1-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bjarni Ingi Gislason <bjarniig@rhi.hi.is>

>From "man ..." ("groff -ww -mandoc ..."):

<groff: tc-drr.8>:67: warning: tab character in unquoted macro argument
<groff: tc-drr.8>:69: warning: tab character in unquoted macro argument

*********************

Originally filed at: http://bugs.debian.org/674706

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 man/man8/tc-drr.8 |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/man8/tc-drr.8 b/man/man8/tc-drr.8
index 16a8ec0..e25d6dd 100644
--- a/man/man8/tc-drr.8
+++ b/man/man8/tc-drr.8
@@ -64,9 +64,9 @@ flow filter:
 
 .B for i in .. 1024;do
 .br
-.B \ttc class add dev ..  classid $handle:$(print %x $i)
+.B "\ttc class add dev .. classid $handle:$(print %x $i)"
 .br
-.B \ttc qdisc add dev .. fifo limit 16
+.B "\ttc qdisc add dev .. fifo limit 16"
 .br
 .B done
 
-- 
1.7.10
