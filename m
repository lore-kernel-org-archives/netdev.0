From: jamal <hadi@cyberus.ca>
Subject: [IPROUTE2 PATCH][XFRM] update xfrm monitoring to use nl_mgrp
Date: Thu, 07 Dec 2006 20:58:23 -0500
Message-ID: <1165543103.3666.18.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-hcDzi10dYMowo0+S7r7X"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.239]:31884 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S938040AbWLHLUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Dec 2006 06:20:33 -0500
Received: by wx-out-0506.google.com with SMTP id h27so797985wxd
        for <netdev@vger.kernel.org>; Fri, 08 Dec 2006 03:20:33 -0800 (PST)
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-hcDzi10dYMowo0+S7r7X
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Stephen,
I will wait until you sync all these patches ive sent; then send a
couple more then i will be done.

cheers,
jamal

--=-hcDzi10dYMowo0+S7r7X
Content-Disposition: attachment; filename=xfrm_event_mg
Content-Type: text/plain; name=xfrm_event_mg; charset=us-ascii
Content-Transfer-Encoding: 7bit

[XFRM] update xfrm monitoring to use nl_mgrp

Signed-off-by: J Hadi Salim <hadi@cyberus.ca>

---
commit 738a5222776694ff22083e54a8f3efb6a013694e
tree 70937ae0b6a80d98d08b4a627fdf7b61f62bdf66
parent 1326d6a1eb107e3b9ea7a3254e621dd3f827bb4d
author Jamal Hadi Salim <hadi@cyberus.ca> Thu, 07 Dec 2006 20:54:50 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Thu, 07 Dec 2006 20:54:50 -0500

 ip/xfrm_monitor.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/ip/xfrm_monitor.c b/ip/xfrm_monitor.c
index b2014b4..925e229 100644
--- a/ip/xfrm_monitor.c
+++ b/ip/xfrm_monitor.c
@@ -292,17 +292,17 @@ int do_xfrm_monitor(int argc, char **argv)
 	}
 
 	if (lacquire)
-		groups |= XFRMGRP_ACQUIRE;
+		groups |= nl_mgrp(XFRMNLGRP_ACQUIRE);
 	if (lexpire)
-		groups |= XFRMGRP_EXPIRE;
+		groups |= nl_mgrp(XFRMNLGRP_EXPIRE);
 	if (lsa)
-		groups |= XFRMGRP_SA;
+		groups |= nl_mgrp(XFRMNLGRP_SA);
 	if (lpolicy)
-		groups |= XFRMGRP_POLICY;
+		groups |= nl_mgrp(XFRMNLGRP_POLICY);
 	if (laevent)
-		groups |= (1 <<  (XFRMNLGRP_AEVENTS - 1));
+		groups |= nl_mgrp(XFRMNLGRP_AEVENTS);
 	if (lreport)
-		groups |= XFRMGRP_REPORT;
+		groups |= nl_mgrp(XFRMNLGRP_REPORT);
 
 	if (file) {
 		FILE *fp;

--=-hcDzi10dYMowo0+S7r7X--

