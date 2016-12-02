From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 01/18] ss: Mark fall through in arg parsing switch()
Date: Fri,  2 Dec 2016 11:39:45 +0100
Message-ID: <20161202104002.17310-2-phil@nwl.cc>
References: <20161202104002.17310-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52299 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934004AbcLBKkT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 05:40:19 -0500
In-Reply-To: <20161202104002.17310-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As there is a certain chance of overlooking this, better add a comment
to draw readers' attention.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/misc/ss.c b/misc/ss.c
index 07dcd8c209c04..469721fd9aee3 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -4223,6 +4223,7 @@ int main(int argc, char *argv[])
 			exit(0);
 		case 'z':
 			show_sock_ctx++;
+			/* fall through */
 		case 'Z':
 			if (is_selinux_enabled() <= 0) {
 				fprintf(stderr, "ss: SELinux is not enabled.\n");
-- 
2.10.0
