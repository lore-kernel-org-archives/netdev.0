From: Tony Zelenoff <antonz@parallels.com>
Subject: [PATCH iproute2 2/2] Adjust man page for new functionality
Date: Thu, 26 Jan 2012 18:50:05 +0400
Message-ID: <1327589405-10930-3-git-send-email-antonz@parallels.com>
References: <1327589405-10930-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devel@openvz.org>, Tony Zelenoff <antonz@parallels.com>,
	<kuznet@ms2.inr.ac.ru>, <netdev@vger.kernel.org>
To: <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:45107 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708Ab2AZOuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 09:50:12 -0500
In-Reply-To: <1327589405-10930-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tony Zelenoff <antonz@parallels.com>
---
 man/man8/ip-neighbour.8 |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/man/man8/ip-neighbour.8 b/man/man8/ip-neighbour.8
index f4ea0db..db383e3 100644
--- a/man/man8/ip-neighbour.8
+++ b/man/man8/ip-neighbour.8
@@ -24,7 +24,7 @@ ip neighbour \- neighbour/arp tables management.
 .IR DEV " ]"
 
 .ti -8
-.BR "ip neigh" " { " show " | " flush " } [ " to
+.BR "ip neigh" " { " show " | " flush " } [ " proxy " ] [ " to
 .IR PREFIX " ] [ "
 .B  dev
 .IR DEV " ] [ "
@@ -133,6 +133,10 @@ the prefix selecting the neighbours to list.
 only list the neighbours attached to this device.
 
 .TP
+.BI proxy
+list neighbour proxies.
+
+.TP
 .B unused
 only list neighbours which are not currently in use.
 
-- 
1.7.1
