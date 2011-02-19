From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 3/3] tracepath: fix typo in -l error message
Date: Sat, 19 Feb 2011 12:51:29 -0500
Message-ID: <1298137889-23969-3-git-send-email-vapier@gentoo.org>
References: <1298137889-23969-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org, Jeroen Roovers <jer@gentoo.org>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:38677 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754231Ab1BSRvd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Feb 2011 12:51:33 -0500
In-Reply-To: <1298137889-23969-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeroen Roovers <jer@gentoo.org>

Signed-off-by: Jeroen Roovers <jer@gentoo.org>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 tracepath.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tracepath.c b/tracepath.c
index 0a14b1b..90e1b28 100644
--- a/tracepath.c
+++ b/tracepath.c
@@ -306,7 +306,7 @@ main(int argc, char **argv)
 			break;
 		case 'l':
 			if ((mtu = atoi(optarg)) <= overhead) {
-				fprintf(stderr, "Error: length must be >= %d\n", overhead);
+				fprintf(stderr, "Error: length must be > %d\n", overhead);
 				exit(1);
 			}
 			break;
-- 
1.7.4.1

