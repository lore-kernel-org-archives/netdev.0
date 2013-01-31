From: "Reeuwijk, C. van" <c.van.reeuwijk@vu.nl>
Subject: [PATCH] iproute2: clarifications in the libnetlink.3 man page
Date: Thu, 31 Jan 2013 16:03:44 +0000
Message-ID: <9C96F25D-CB12-42BC-99C4-CBB70741E967@cs.vu.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.vu.nl ([130.37.164.18]:7167 "EHLO mailin.vu.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755190Ab3AaQJM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 11:09:12 -0500
Content-Language: en-US
Content-ID: <C2F5B524BF9E7A4CB7D6B06E6F375D31@ad.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 From: Kees van Reeuwijk <reeuwijk@few.vu.nl>

Rephrasing for clarity.


Signed-off-by: Kees van Reeuwijk <reeuwijk@few.vu.nl>

---

 libnetlink.3 |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/libnetlink.3 b/libnetlink.3
index 15a478a..4c70678 100644
--- a/libnetlink.3
+++ b/libnetlink.3
@@ -100,7 +100,7 @@ in case of error. NULL for
 means to not use a filter.
 .B junk
 is used to filter messages not destined to the local socket.
-Only one message bundle is received. Unless there is no message 
+Only one message bundle is received. If there is a message 
 pending, this function does not block.
 
 .TP
@@ -112,7 +112,7 @@ is a callback that gets the message source address, the message itself,
 and the
 .B jarg
 cookie as arguments. It will get called for all received messages.
-Only one message bundle is received. Unless there is no message 
+Only one message bundle is received. If there is a message 
 pending this function does not block.
 
 .TP
@@ -123,7 +123,7 @@ but reads a netlink message bundle from the file
 .B file
 and passes the messages to
 .B handler
-for parsing. The file contains raw data as received from a rtnetlink socket.
+for parsing. The file should contain raw data as received from a rtnetlink socket.
 .PP
 The following functions are useful to construct custom rtnetlink messages. For
 simple database dumping with filtering it is better to use the higher level

-- 
Dr. ir. Kees van Reeuwijk, Vrije Universiteit Amsterdam
