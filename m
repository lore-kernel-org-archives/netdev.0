From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] Fix warning for token-ring from sysctl checker
Date: Tue, 13 Nov 2007 01:23:13 -0600
Message-ID: <20071113072313.GB16842@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:59590 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750853AbXKMHWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 02:22:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As seen when booting ppc64_defconfig:

sysctl table check failed: /net/token-ring .3.14 procname does not match binary path procname


Signed-off-by: Olof Johansson <olof@lixom.net>

diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
index 5a2f2b2..4abc6d2 100644
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -738,7 +738,7 @@ static struct trans_ctl_table trans_net_table[] = {
 	{ NET_ROSE,		"rose",		trans_net_rose_table },
 	{ NET_IPV6,		"ipv6",		trans_net_ipv6_table },
 	{ NET_X25,		"x25",		trans_net_x25_table },
-	{ NET_TR,		"tr",		trans_net_tr_table },
+	{ NET_TR,		"token-ring",	trans_net_tr_table },
 	{ NET_DECNET,		"decnet",	trans_net_decnet_table },
 	/*  NET_ECONET not used */
 	{ NET_SCTP,		"sctp",		trans_net_sctp_table },
