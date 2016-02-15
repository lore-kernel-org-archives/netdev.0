From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next 3/3] ila: autoload module
Date: Mon, 15 Feb 2016 15:42:03 +0000
Message-ID: <1455550923-23673-4-git-send-email-rshearma@brocade.com>
References: <1455550923-23673-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Tom Herbert" <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jiri Benc <jbenc@redhat.com>,
	"Robert Shearman" <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:64744 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751675AbcBOPnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 10:43:02 -0500
In-Reply-To: <1455550923-23673-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid users having to manually load the module by adding a module
alias allowing it to be autoloaded by the lwt infra.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/ipv6/ila/ila_common.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/ila/ila_common.c b/net/ipv6/ila/ila_common.c
index 32dc9aab7297..8ecf2482560e 100644
--- a/net/ipv6/ila/ila_common.c
+++ b/net/ipv6/ila/ila_common.c
@@ -99,5 +99,6 @@ static void __exit ila_fini(void)
 
 module_init(ila_init);
 module_exit(ila_fini);
+MODULE_ALIAS_RTNL_LWT(LWTUNNEL_ENCAP_ILA);
 MODULE_AUTHOR("Tom Herbert <tom@herbertland.com>");
 MODULE_LICENSE("GPL");
-- 
2.1.4
