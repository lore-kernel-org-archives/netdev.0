From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next v2 2/3] mpls: autoload lwt module
Date: Fri, 19 Feb 2016 09:43:17 +0000
Message-ID: <1455874998-26795-3-git-send-email-rshearma@brocade.com>
References: <1455550923-23673-1-git-send-email-rshearma@brocade.com>
 <1455874998-26795-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Tom Herbert" <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jiri Benc <jbenc@redhat.com>,
	"Robert Shearman" <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:60025 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161952AbcBSJn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 04:43:58 -0500
In-Reply-To: <1455874998-26795-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid users having to manually load the module by adding a module
alias allowing it to be autoloaded by the lwt infra.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/mpls/mpls_iptunnel.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index fb31aa87de81..644a8da6d4bd 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -227,5 +227,6 @@ static void __exit mpls_iptunnel_exit(void)
 }
 module_exit(mpls_iptunnel_exit);
 
+MODULE_ALIAS_RTNL_LWT(MPLS);
 MODULE_DESCRIPTION("MultiProtocol Label Switching IP Tunnels");
 MODULE_LICENSE("GPL v2");
-- 
2.1.4
