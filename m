From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] mpls_iptunnel: add static qualifier to mpls_output
Date: Wed,  9 Dec 2015 06:56:41 -0800
Message-ID: <1449673001-27596-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: ebiederm@xmission.com, rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33720 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbbLIO4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 09:56:46 -0500
Received: by pfnn128 with SMTP id n128so31203376pfn.0
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 06:56:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This gets rid of the following compile warn:
net/mpls/mpls_iptunnel.c:40:5: warning: no previous prototype for
mpls_output [-Wmissing-prototypes]

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/mpls/mpls_iptunnel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index 67591ae..cdd01e6 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -37,7 +37,7 @@ static unsigned int mpls_encap_size(struct mpls_iptunnel_encap *en)
 	return en->labels * sizeof(struct mpls_shim_hdr);
 }
 
-int mpls_output(struct net *net, struct sock *sk, struct sk_buff *skb)
+static int mpls_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct mpls_iptunnel_encap *tun_encap_info;
 	struct mpls_shim_hdr *hdr;
-- 
1.9.1
