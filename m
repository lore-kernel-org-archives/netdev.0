From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [PATCH iproute2 0/3] iplink: shortify printing the usage of bridge
Date: Wed, 12 Aug 2015 06:03:21 +0000
Message-ID: <1439359404-5085-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:2371 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933636AbbHLGAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 02:00:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set enables bridge related links to print usage with short format.
Or else it is needed to use the following way:
	    
  ip link { add | del | set } type TYPE help

Zhang Shengju (3):
  iplink: add missing link type
  iplink: use the short format to print help info
  iplink: shortify printing the usage of link type

 ip/iplink.c              |  2 +-
 ip/iplink_bridge.c       | 16 ++++++++++++++--
 ip/iplink_bridge_slave.c | 16 ++++++++++++++--
 3 files changed, 29 insertions(+), 5 deletions(-)

-- 
1.8.3.1
