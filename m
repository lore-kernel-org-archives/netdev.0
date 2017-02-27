From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/6] uapi: stop including linux/sysctl.h in uapi/linux/netfilter.h
Date: Mon, 27 Feb 2017 12:35:38 +0100
Message-ID: <1488195342-2678-3-git-send-email-pablo@netfilter.org>
References: <1488195342-2678-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48540 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752080AbdB0Lgo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Feb 2017 06:36:44 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id C7156E651
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 12:35:59 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B5DD9DA816
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 12:35:59 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 516F6DA816
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 12:35:54 +0100 (CET)
In-Reply-To: <1488195342-2678-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry V. Levin" <ldv@altlinux.org>

linux/netfilter.h is the last uapi header file that includes
linux/sysctl.h but it does not depend on definitions provided
by this essentially dead header file.

Suggested-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/uapi/linux/netfilter.h b/include/uapi/linux/netfilter.h
index 7550e9176a54..c111a91adcc0 100644
--- a/include/uapi/linux/netfilter.h
+++ b/include/uapi/linux/netfilter.h
@@ -3,7 +3,6 @@
 
 #include <linux/types.h>
 #include <linux/compiler.h>
-#include <linux/sysctl.h>
 #include <linux/in.h>
 #include <linux/in6.h>
 
-- 
2.1.4
