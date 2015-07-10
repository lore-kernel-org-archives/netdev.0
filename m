From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC net-next 01/22] rtnetlink: introduce new RTA_ENCAP_TYPE and RTA_ENCAP attributes
Date: Fri, 10 Jul 2015 16:19:03 +0200
Message-ID: <83401c5d1b875106a898e3b3032abfc8344049f9.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40486 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932670AbbGJOTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 10:19:35 -0400
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch introduces two new RTA attributes to attach encap
data to fib routes.

Example iproute2 command to attach mpls encap data to ipv4 routes

$ip route add 10.1.1.0/30 encap mpls 200 via inet 10.1.1.1 dev swp1

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Suggested-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/uapi/linux/rtnetlink.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index fdd8f07..0d3d3cc 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -308,6 +308,8 @@ enum rtattr_type_t {
 	RTA_VIA,
 	RTA_NEWDST,
 	RTA_PREF,
+	RTA_ENCAP_TYPE,
+	RTA_ENCAP,
 	__RTA_MAX
 };
 
-- 
2.4.3
