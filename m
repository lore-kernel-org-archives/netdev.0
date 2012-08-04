From: Nick Alcock <nick.alcock@oracle.com>
Subject: [PATCH iproute2] Install the bridge command under the same name we build it.
Date: Sat, 04 Aug 2012 15:36:05 +0100
Message-ID: <87ehnmiv1m.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:32124 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752757Ab2HDOgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 10:36:10 -0400
Received: from acsinet21.oracle.com (acsinet21.oracle.com [141.146.126.237])
	by acsinet15.oracle.com (Sentrion-MTA-4.2.2/Sentrion-MTA-4.2.2) with ESMTP id q74Ea8YG005211
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Sat, 4 Aug 2012 14:36:09 GMT
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by acsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id q74Ea7Pm017187
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 4 Aug 2012 14:36:08 GMT
Received: from abhmt109.oracle.com (abhmt109.oracle.com [141.146.116.61])
	by acsmt356.oracle.com (8.12.11.20060308/8.12.11) with ESMTP id q74Ea7xg011572
	for <netdev@vger.kernel.org>; Sat, 4 Aug 2012 09:36:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Nick Alcock <nick.alcock@oracle.com>
---
 bridge/Makefile | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/bridge/Makefile b/bridge/Makefile
index 0c333bf..9a6743e 100644
--- a/bridge/Makefile
+++ b/bridge/Makefile
@@ -7,8 +7,8 @@ all: bridge
 bridge: $(BROBJ) $(LIBNETLINK) 
 
 install: all
-	install -m 0755 br $(DESTDIR)$(SBINDIR)
+	install -m 0755 bridge $(DESTDIR)$(SBINDIR)
 
 clean:
-	rm -f $(BROBJ) br
+	rm -f $(BROBJ) bridge
 
-- 
1.7.11.2.155.g5ceeb62
