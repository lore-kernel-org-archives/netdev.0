From: Kees van Reeuwijk <kees.van.reeuwijk@gmail.com>
Subject: [PATCH v2 2/5] iproute2: clarifications in the libnetlink.3 man
 page
Date: Fri, 08 Feb 2013 14:32:36 +0100
Message-ID: <E1U3o4C-0000bx-O4@babylon.few.vu.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:33887 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946057Ab3BHNek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 08:34:40 -0500
Received: by mail-we0-f173.google.com with SMTP id r5so3018045wey.18
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 05:34:38 -0800 (PST)
Received: from reeuwijk by babylon.few.vu.nl with local (Exim 4.72)
	(envelope-from <reeuwijk@few.vu.nl>)
	id 1U3o4C-0000bx-O4
	for netdev@vger.kernel.org; Fri, 08 Feb 2013 14:32:36 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees van Reeuwijk <reeuwijk@few.vu.nl>

Rephrasing for clarity.


Signed-off-by: Kees van Reeuwijk <reeuwijk@few.vu.nl>

 ---

 libnetlink.3 |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/man/man3/libnetlink.3 b/man/man3/libnetlink.3
index d114169..e999bd6 100644
--- a/man/man3/libnetlink.3
+++ b/man/man3/libnetlink.3
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
