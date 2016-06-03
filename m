From: Dan Streetman <dan.streetman@canonical.com>
Subject: [PATCH 4.4-stable 0/3] Set a large MTU on ovs-created tunnel devices
Date: Fri,  3 Jun 2016 18:58:12 -0400
Message-ID: <1464994695-25178-1-git-send-email-dan.streetman@canonical.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:56146 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416AbcFCXDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 19:03:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can you queue these for 4.4 stable?  The first 2 are cherry-picked cleanly
into 4.4, the last required only context changes to apply.

The commits are only needed in 4.4, as the bugs they fix were introduced
after 4.1.

David Wragg (3):
  vxlan: Relax MTU constraints
  geneve: Relax MTU constraints
  vxlan, gre, geneve: Set a large MTU on ovs-created tunnel devices

 drivers/net/geneve.c          | 31 +++++++++++++++++++++++-----
 drivers/net/vxlan.c           | 47 ++++++++++++++++++++++++++++++-------------
 include/net/ip_tunnels.h      |  1 +
 net/ipv4/ip_gre.c             |  8 ++++++++
 net/ipv4/ip_tunnel.c          | 20 +++++++++++++++---
 net/openvswitch/vport-vxlan.c |  2 ++
 6 files changed, 87 insertions(+), 22 deletions(-)

-- 
2.7.4
