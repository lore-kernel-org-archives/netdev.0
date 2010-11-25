From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH]ipv6: kill two unused macro definition
Date: Thu, 25 Nov 2010 15:47:56 +0800
Message-ID: <4CEE14AC.7090008@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Network-Maillist <netdev@vger.kernel.org>, adobriyan@sw.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64362 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751054Ab0KYHth (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Nov 2010 02:49:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. IPV6_TLV_TEL_DST_SIZE
This has not been using for several years since created.

2. RT6_INFO_LEN
commit 33120b30 kill all RT6_INFO_LEN's references, but only this definition remained.

commit 33120b30cc3b8665204d4fcde7288638b0dd04d5
Author: Alexey Dobriyan <adobriyan@sw.ru>
Date:   Tue Nov 6 05:27:11 2007 -0800

    [IPV6]: Convert /proc/net/ipv6_route to seq_file interface


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
For this cleanup and trival patch, don't split in two.
---
 net/ipv6/ip6_tunnel.c |    2 --
 net/ipv6/route.c      |    2 --
 2 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 2a59610..b115555 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -58,8 +58,6 @@ MODULE_AUTHOR("Ville Nuorvala");
 MODULE_DESCRIPTION("IPv6 tunneling device");
 MODULE_LICENSE("GPL");
 
-#define IPV6_TLV_TEL_DST_SIZE 8
-
 #ifdef IP6_TNL_DEBUG
 #define IP6_TNL_TRACE(x...) printk(KERN_DEBUG "%s:" x "\n", __func__)
 #else
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 96455ff..e05babe 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2465,8 +2465,6 @@ static int ip6_route_dev_notify(struct notifier_block *this,
 
 #ifdef CONFIG_PROC_FS
 
-#define RT6_INFO_LEN (32 + 4 + 32 + 4 + 32 + 40 + 5 + 1)
-
 struct rt6_proc_arg
 {
 	char *buffer;
-- 
1.6.3.3

