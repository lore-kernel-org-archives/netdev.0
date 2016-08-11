From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 0/3] lwtunnel, mpls fragmentation and gso fixes
Date: Wed, 10 Aug 2016 23:43:29 -0700
Message-ID: <1470897812-8213-1-git-send-email-roopa@cumulusnetworks.com>
Cc: dsa@cumulusnetworks.com, buytenh@wantstofly.org,
	ebiederm@xmission.com, rshearma@brocade.com,
	simon.horman@netronome.com, tom@herbertland.com, tgraf@suug.ch,
	olivier.dugeon@orange.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34121 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932211AbcHKGuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 02:50:09 -0400
Received: by mail-pf0-f180.google.com with SMTP id p64so23814383pfb.1
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 23:50:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This series fixes a few issues around mtu and fragmentation
for tunnels using lwtunnel output redirect and also fixes
a few gso issues recently reported by Lennert Buytenhek.

David Ahern (2):
  net: mpls fixes for GSO
  net: veth: set features for MPLS

Roopa Prabhu (1):
  lwtunnel: xmit redirect

 drivers/net/veth.c       |  1 +
 include/net/lwtunnel.h   | 44 ++++++++++++++++++++++++++++++++++++++++++++
 net/core/lwtunnel.c      | 35 +++++++++++++++++++++++++++++++++++
 net/ipv4/ip_output.c     |  8 ++++++++
 net/ipv4/route.c         |  4 +++-
 net/ipv6/ip6_output.c    |  8 ++++++++
 net/ipv6/route.c         |  4 +++-
 net/mpls/mpls_gso.c      | 24 ++++++++++++++++--------
 net/mpls/mpls_iptunnel.c | 16 ++++++++++++----
 9 files changed, 130 insertions(+), 14 deletions(-)

-- 
1.9.1
