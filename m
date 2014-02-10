From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH iproute2 net-next-for-3.13 0/2] iproute2: display bonding slave info
Date: Mon, 10 Feb 2014 09:11:36 +0100 (CET)
Message-ID: <20140210081136.66C22E5697@unicorn.suse.cz>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43736 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751018AbaBJILi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Feb 2014 03:11:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since v3.14-rc1, kernel provides rtnetlink interface for read-only
access to bonding slave parameters. Show this info in the output of
"ip -d link show" command. The implementation is divided into generic
part (add a callback to struct link_util and call it from
print_linktype()) and bonding specific part (provide the callback in
iplink_bond.c).

Michal Kubecek (2):
  iplink: display slave information
  iplink_bond: add support for displaying bond slave attributes

 ip/ip_common.h   |  3 +++
 ip/ipaddress.c   | 27 +++++++++++++++++++++++--
 ip/iplink_bond.c | 61 ++++++++++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 85 insertions(+), 6 deletions(-)

-- 
1.8.1.4
