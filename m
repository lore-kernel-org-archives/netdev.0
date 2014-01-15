From: Thomas Haller <thaller@redhat.com>
Subject: [PATCH v5 0/2] ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to suppress creation of IP6 routes
Date: Wed, 15 Jan 2014 15:36:57 +0100
Message-ID: <1389796619-13440-1-git-send-email-thaller@redhat.com>
References: <20140110.181030.2081631538801450145.davem@davemloft.net>
Cc: hannes@stressinduktion.org, jiri@resnulli.us,
	netdev@vger.kernel.org, stephen@networkplumber.org,
	dcbw@redhat.com, Thomas Haller <thaller@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2011 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751683AbaAOOhU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 09:37:20 -0500
In-Reply-To: <20140110.181030.2081631538801450145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1 -> v2: add a second commit, handling NOPREFIXROUTE in ip6_del_addr.
v2 -> v3: reword commit messages, code comments and some refactoring.
v3 -> v4: refactor, rename variables, add enum
v4 -> v5: rebase, so that patch applies cleanly to current net-next/master

Thomas Haller (2):
  ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to suppress creation of
    IP6 routes
  ipv6 addrconf: don't cleanup prefix route for IFA_F_NOPREFIXROUTE

 include/uapi/linux/if_addr.h |   1 +
 net/ipv6/addrconf.c          | 203 ++++++++++++++++++++++++++-----------------
 2 files changed, 123 insertions(+), 81 deletions(-)

-- 
1.8.4.2
