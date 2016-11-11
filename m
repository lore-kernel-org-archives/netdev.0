From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 01/18] ss: Mark fall through in arg parsing switch()
Date: Fri, 11 Nov 2016 14:09:57 +0100
Message-ID: <20161111131014.21865-2-phil@nwl.cc>
References: <20161111131014.21865-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:43478 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756670AbcKKNLf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 08:11:35 -0500
In-Reply-To: <20161111131014.21865-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As there is a certain chance of overlooking this, better add a comment
to draw readers' attention.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/misc/ss.c b/misc/ss.c
index dd77b8153b6da..c20bfbdb01c62 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -4025,6 +4025,7 @@ int main(int argc, char *argv[])
 			exit(0);
 		case 'z':
 			show_sock_ctx++;
+			/* fall through */
 		case 'Z':
 			if (is_selinux_enabled() <= 0) {
 				fprintf(stderr, "ss: SELinux is not enabled.\n");
-- 
2.10.0
