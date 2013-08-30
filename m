From: Daniel Borkmann <dborkman@redhat.com>
Subject: [RFC PATCH net-next 0/7] IPv6 MLD updates
Date: Fri, 30 Aug 2013 18:58:21 +0200
Message-ID: <1377881908-8022-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6256 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756773Ab3H3Q6a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 12:58:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If there are no further objections, I'll send out the non-RFC version on
Monday after some more testing. That's just a heads up. This set includes
my improved fix from yesterday as well besides other things.

Thanks!

Daniel Borkmann (7):
  net: ipv6: mld: fix v1/v2 switchback timeout to rfc3810, 9.12.
  net: ipv6: mld: clean up MLD_V1_SEEN macro
  net: ipv6: mld: get rid of MLDV2_MRC and simplify calculation
  net: ipv6: mld: implement RFC3810 MLDv2 mode only
  net: ipv6: mld: restrict min/max of sysctl force_mld_version
  net: ipv6: mld: similarly to MLDv2 have min max_delay of 1
  net: ipv6: mld: document force_mld_version in ip-sysctl.txt

 Documentation/networking/ip-sysctl.txt |   5 ++
 include/net/if_inet6.h                 |   9 +-
 include/net/mld.h                      |  51 +++++++++--
 net/bridge/br_multicast.c              |   3 +-
 net/ipv6/addrconf.c                    |   7 +-
 net/ipv6/mcast.c                       | 159 +++++++++++++++++++++++++++------
 6 files changed, 195 insertions(+), 39 deletions(-)

-- 
1.7.11.7
