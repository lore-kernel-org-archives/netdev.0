From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2] allow to create temporary addresses
Date: Thu, 24 Oct 2013 15:48:59 +0200
Message-ID: <1382622539-6653-1-git-send-email-jiri@resnulli.us>
References: <1382622355-6500-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:41597 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754722Ab3JXNvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 09:51:09 -0400
Received: by mail-ea0-f178.google.com with SMTP id a15so1236145eae.37
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 06:51:08 -0700 (PDT)
In-Reply-To: <1382622355-6500-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 ip/ipaddress.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 1c3e4da..3ca774d 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1332,6 +1332,9 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 			req.ifa.ifa_flags |= IFA_F_HOMEADDRESS;
 		} else if (strcmp(*argv, "nodad") == 0) {
 			req.ifa.ifa_flags |= IFA_F_NODAD;
+		} else if (strcmp(*argv, "temporary") == 0 ||
+			   strcmp(*argv, "secondary") == 0) {
+			req.ifa.ifa_flags |= IFA_F_SECONDARY;
 		} else {
 			if (strcmp(*argv, "local") == 0) {
 				NEXT_ARG();
-- 
1.8.3.1
