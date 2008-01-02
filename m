From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] iproute2: revert syntax help text mistake.
Date: Thu, 03 Jan 2008 00:47:30 +0100
Message-ID: <1199317650.16358.54.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:50187 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491AbYABXoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 18:44:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry. The pref and prio options are actually synonyms.
This reverts part of commit 576c63ee59de3f18bec4ebd8181a5a395f268d03.

Signed-off-by: Andreas Henriksson <andreas@fatal.se>

--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -38,7 +38,7 @@ static void usage(void)
 {
 	fprintf(stderr, "Usage: ip rule [ list | add | del | flush ] SELECTOR ACTION\n");
 	fprintf(stderr, "SELECTOR := [ not ] [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK[/MASK] ]\n");
-	fprintf(stderr, "            [ dev STRING ] [ pref NUMBER ] [ prio NUMBER ]\n");
+	fprintf(stderr, "            [ dev STRING ] [ pref NUMBER ]\n");
 	fprintf(stderr, "ACTION := [ table TABLE_ID ]\n");
 	fprintf(stderr, "          [ prohibit | reject | unreachable ]\n");
 	fprintf(stderr, "          [ realms [SRCREALM/]DSTREALM ]\n");


