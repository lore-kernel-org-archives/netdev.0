From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [RFC PATCH net-next 1/5] ip_tunnels: new IP_TUNNEL_INFO_BRIDGE flag for ip_tunnel_info mode
Date: Fri, 20 Jan 2017 21:46:52 -0800
Message-ID: <1484977616-1541-2-git-send-email-roopa@cumulusnetworks.com>
References: <1484977616-1541-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34753 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750800AbdAUFrC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2017 00:47:02 -0500
Received: by mail-pf0-f174.google.com with SMTP id e4so27427852pfg.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 21:47:02 -0800 (PST)
In-Reply-To: <1484977616-1541-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

New ip_tunnel_info flag to represent bridged tunnel metadata.
Used by bridge driver later in the series to pass per vlan dst
metadata to bridge ports.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/net/ip_tunnels.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 3d4ca4d..9505679 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -58,6 +58,7 @@ struct ip_tunnel_key {
 /* Flags for ip_tunnel_info mode. */
 #define IP_TUNNEL_INFO_TX	0x01	/* represents tx tunnel parameters */
 #define IP_TUNNEL_INFO_IPV6	0x02	/* key contains IPv6 addresses */
+#define IP_TUNNEL_INFO_BRIDGE	0x04	/* represents a bridged tunnel id */
 
 /* Maximum tunnel options length. */
 #define IP_TUNNEL_OPTS_MAX					\
-- 
1.7.10.4
