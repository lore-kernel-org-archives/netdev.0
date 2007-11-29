From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCHv7 iproute2 1/2] Added IFLA_NET_NS_PID as in kernel v2.6.24-rc1
Date: Thu, 29 Nov 2007 17:11:48 +0100
Message-ID: <11963527101123-git-send-email-panther@balabit.hu>
References: <11963527094077-git-send-email-panther@balabit.hu>
 <11963527103201-git-send-email-panther@balabit.hu>
 <1196352710402-git-send-email-panther@balabit.hu>
 <11963527101876-git-send-email-panther@balabit.hu>
 <11963527103391-git-send-email-panther@balabit.hu>
 <11963527102332-git-send-email-panther@balabit.hu>
 <11963527101629-git-send-email-panther@balabit.hu>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:38144 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757600AbXK2QMB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 11:12:01 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id A0453C1481
	for <netdev@vger.kernel.org>; Thu, 29 Nov 2007 17:12:00 +0100 (CET)
In-Reply-To: <11963527101629-git-send-email-panther@balabit.hu>
In-Reply-To: <ifgroup-20071129-165736-1196351856-panther@balabit.hu>
References: <ifgroup-20071129-165736-1196351856-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 23b3a8e..c948395 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -78,6 +78,7 @@ enum
 	IFLA_LINKMODE,
 	IFLA_LINKINFO,
 #define IFLA_LINKINFO IFLA_LINKINFO
+	IFLA_NET_NS_PID,
 	__IFLA_MAX
 };
 
-- 
1.5.2.5

