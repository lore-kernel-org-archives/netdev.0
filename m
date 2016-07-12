From: Davide Caratti <dcaratti@redhat.com>
Subject: [iproute PATCH] ip-macsec.8: fix typo in 'examples' section
Date: Tue, 12 Jul 2016 10:19:00 +0200
Message-ID: <49c1e540558e6b6ea422872e8bd4e8501e07e25a.1468310945.git.dcaratti@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59747 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750787AbcGLITq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 04:19:46 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3F54185366
	for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 08:19:46 +0000 (UTC)
Received: from dhcp-176-224.mxp.redhat.com (dhcp-176-224.mxp.redhat.com [10.32.176.224])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u6C8JjHH022619
	for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 04:19:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix wrong 'device' keyword in 'ip link add device eth0'

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 man/man8/ip-macsec.8 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ip-macsec.8 b/man/man8/ip-macsec.8
index e8455d7..03ed700 100644
--- a/man/man8/ip-macsec.8
+++ b/man/man8/ip-macsec.8
@@ -74,7 +74,7 @@ type.
 .PP
 .SS Create a MACsec device on link eth0
 .nf
-# ip link add device eth0 macsec0 type macsec port 11 encrypt on
+# ip link add link eth0 macsec0 type macsec port 11 encrypt on
 .PP
 .SS Configure a secure association on that device
 .nf
-- 
2.5.5
