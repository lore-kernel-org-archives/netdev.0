From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/3] follow-up improvements for ipv6 tokens
Date: Tue,  9 Apr 2013 15:47:13 +0200
Message-ID: <1365515236-7154-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42408 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760288Ab3DINrU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 09:47:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set implements follow-up suggestions from Hannes for commit
f53adae4eae5ad9 (``net: ipv6: add tokenized interface identifier
support''). Tested by myself.

Daniel Borkmann (3):
  net: ipv6: minor: use in6addr_any in token init
  net: ipv6: also allow token to be set when device not ready
  net: ipv6: only invalidate previously tokenized addresses

 include/net/if_inet6.h |    2 ++
 net/ipv6/addrconf.c    |   31 ++++++++++++++++++++++---------
 2 files changed, 24 insertions(+), 9 deletions(-)
