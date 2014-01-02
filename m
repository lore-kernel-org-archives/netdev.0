From: Thomas Haller <thaller@redhat.com>
Subject: [PATCH 1/1] fixup! add support for IFA_F_MANAGETEMPADDR
Date: Thu,  2 Jan 2014 16:50:15 +0100
Message-ID: <1388677815-5815-1-git-send-email-thaller@redhat.com>
References: <1388676879-2603-3-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, Jiri Pirko <jiri@resnulli.us>,
	Thomas Haller <thaller@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48171 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750914AbaABPuf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 10:50:35 -0500
In-Reply-To: <1388676879-2603-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Haller <thaller@redhat.com>
---
 I think, also the following changes are needed(??)

 ip/ipaddress.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 5dbb017..b0d54fe 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -82,7 +82,7 @@ static void usage(void)
 	fprintf(stderr, "           tentative | deprecated | dadfailed | temporary |\n");
 	fprintf(stderr, "           CONFFLAG-LIST ]\n");
 	fprintf(stderr, "CONFFLAG-LIST := [ CONFFLAG-LIST ] CONFFLAG\n");
-	fprintf(stderr, "CONFFLAG  := [ home | nodad ]\n");
+	fprintf(stderr, "CONFFLAG  := [ home | nodad | mngtmpaddr ]\n");
 	fprintf(stderr, "LIFETIME := [ valid_lft LFT ] [ preferred_lft LFT ]\n");
 	fprintf(stderr, "LFT := forever | SECONDS\n");
 
@@ -1130,6 +1130,9 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 		} else if (strcmp(*argv, "nodad") == 0) {
 			filter.flags |= IFA_F_NODAD;
 			filter.flagmask |= IFA_F_NODAD;
+		} else if (strcmp(*argv, "mngtmpaddr") == 0) {
+			filter.flags |= IFA_F_MANAGETEMPADDR;
+			filter.flagmask |= IFA_F_MANAGETEMPADDR;
 		} else if (strcmp(*argv, "dadfailed") == 0) {
 			filter.flags |= IFA_F_DADFAILED;
 			filter.flagmask |= IFA_F_DADFAILED;
-- 
1.8.4.2
