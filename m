From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH 02/12] Add parameters to usage help text.
Date: Fri, 12 Oct 2007 10:56:37 +0200
Message-ID: <1192179407-22461-2-git-send-email-andreas@fatal.se>
References: <1192179407-22461-1-git-send-email-andreas@fatal.se>
Cc: netdev@vger.kernel.org, Alexander Wirt <formorer@debian.org>,
	Andreas Henriksson <andreas@fatal.se>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:38416 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758617AbXJLI5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 04:57:54 -0400
In-Reply-To: <1192179407-22461-1-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Wirt <formorer@debian.org>

Add src option to route help text (http://bugs.debian.org/226142).
Add prio option to rule prio help text (http://bugs.debian.org/213673).

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 ip/iproute.c |    2 +-
 ip/iprule.c  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 77bdf83..d3a3243 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -74,7 +74,7 @@ static void usage(void)
 	fprintf(stderr, "OPTIONS := FLAGS [ mtu NUMBER ] [ advmss NUMBER ]\n");
 	fprintf(stderr, "           [ rtt TIME ] [ rttvar TIME ]\n");
 	fprintf(stderr, "           [ window NUMBER] [ cwnd NUMBER ] [ initcwnd NUMBER ]\n");
-	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ]\n");
+	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ] [ src ADDRESS ]\n");
 	fprintf(stderr, "           [ rto_min TIME ]\n");
 	fprintf(stderr, "TYPE := [ unicast | local | broadcast | multicast | throw |\n");
 	fprintf(stderr, "          unreachable | prohibit | blackhole | nat ]\n");
diff --git a/ip/iprule.c b/ip/iprule.c
index e1a943a..0f7c223 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -38,7 +38,7 @@ static void usage(void)
 {
 	fprintf(stderr, "Usage: ip rule [ list | add | del | flush ] SELECTOR ACTION\n");
 	fprintf(stderr, "SELECTOR := [ not ] [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK[/MASK] ]\n");
-	fprintf(stderr, "            [ dev STRING ] [ pref NUMBER ]\n");
+	fprintf(stderr, "            [ dev STRING ] [ pref NUMBER ] [ prio NUMBER ]\n");
 	fprintf(stderr, "ACTION := [ table TABLE_ID ]\n");
 	fprintf(stderr, "          [ prohibit | reject | unreachable ]\n");
 	fprintf(stderr, "          [ realms [SRCREALM/]DSTREALM ]\n");
-- 
1.5.3.4

