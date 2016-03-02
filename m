From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 15/20] man: ip-token.8: Review synopsis section
Date: Wed,  2 Mar 2016 19:20:03 +0100
Message-ID: <1456942808-15946-16-git-send-email-phil@nwl.cc>
References: <20160302093800.7e7dbe71@xeon-e3>
 <1456942808-15946-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:40255 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755042AbcCBSU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 13:20:58 -0500
In-Reply-To: <1456942808-15946-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drop unnecessary curly braces around single action keywords, point out
that 'dev' parameter to 'ip token get' is optional and clarify that 'ip
token' defaults to 'list' action.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-token.8 | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/man/man8/ip-token.8 b/man/man8/ip-token.8
index 35a3d1e3e45bf..260f366af196f 100644
--- a/man/man8/ip-token.8
+++ b/man/man8/ip-token.8
@@ -7,23 +7,23 @@ ip-token \- tokenized interface identifier support
 .in +8
 .ti -8
 .B ip token
-.RI " { " COMMAND " | "
+.RI "{ " COMMAND " | "
 .BR help " }"
 .sp
 
 .ti -8
-.BR "ip token" " { " set " } "
+.B ip token set
 .IR TOKEN
 .B dev
 .IR DEV
 
 .ti -8
-.BR "ip token" " { " get " } "
-.B dev
-.IR DEV
+.B ip token get
+.RB "[ " dev
+.IR DEV " ]"
 
 .ti -8
-.BR "ip token" " { " list " }"
+.BR "ip token" " [ " list " ]"
 
 .SH "DESCRIPTION"
 IPv6 tokenized interface identifier support is used for assigning well-known
-- 
2.7.2
