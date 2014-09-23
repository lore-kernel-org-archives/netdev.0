From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/3] mld updates, part 2
Date: Tue, 23 Sep 2014 09:03:45 +0200
Message-ID: <1411455828-5196-1-git-send-email-dborkman@redhat.com>
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30249 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753041AbaIWHD5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 03:03:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann (3):
  ipv6: mld: rename mc_maxdelay into mc_uri
  ipv6: mld: do not overwrite uri when receiving an mldv2 query
  ipv6: mld: remove duplicate code from mld_update_qri

 include/net/if_inet6.h |  2 +-
 net/ipv6/mcast.c       | 31 ++++++++++++-------------------
 2 files changed, 13 insertions(+), 20 deletions(-)

-- 
1.7.11.7
