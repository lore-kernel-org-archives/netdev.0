From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next 0/2] lwtunnel: encap locally-generated ipv4 packets
Date: Mon, 3 Aug 2015 17:39:19 +0100
Message-ID: <1438619961-15919-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Robert Shearman" <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:14862 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754009AbbHCQkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 12:40:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Locally-generated IPv4 packets, such as from applications running on
the host or traceroute/ping currently don't have lwtunnel output
redirected encap applied. However, they should do in the same way as
for forwarded packets and this patch series addresses that.

Robert Shearman (2):
  lwtunnel: set skb protocol and dev
  ipv4: apply lwtunnel encap for locally-generated packets

 net/core/lwtunnel.c | 12 ++++++++++--
 net/ipv4/route.c    |  2 ++
 2 files changed, 12 insertions(+), 2 deletions(-)

-- 
2.1.4
