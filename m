From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/2] Minor vf_info review
Date: Wed,  1 Jun 2016 22:03:48 +0200
Message-ID: <1464811430-19415-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:48736 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750742AbcFAUED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2016 16:04:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While implementing the display of IFLA_VF_QUERY_RSS_EN value in
ip-address (see patch 2/2), I stumbled upon some dubious constructs in
print_vfinfo() and replaced them with code which seems more intuitive to
me (see patch 1/2 for details).

Phil Sutter (2):
  ipaddress: Simplify vf_info parsing
  ipaddress: Print IFLA_VF_QUERY_RSS_EN setting

 ip/ipaddress.c | 52 ++++++++++++++++++----------------------------------
 1 file changed, 18 insertions(+), 34 deletions(-)

-- 
2.8.2
