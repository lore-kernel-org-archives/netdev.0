From: Thomas Haller <thaller@redhat.com>
Subject: [PATCH v3 0/2] ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to suppress creation of IP6 routes
Date: Wed,  8 Jan 2014 01:41:26 +0100
Message-ID: <1389141688-25618-1-git-send-email-thaller@redhat.com>
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com,
	Thomas Haller <thaller@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59864 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751350AbaAHAlx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 19:41:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New version, obsoletes the two previous attempts.

v1 -> v2: add a second commit, handling NOPREFIXROUTE in ip6_del_addr.
v2 -> v3: reword commit messages, code comments and some refactoring.

Thomas Haller (2):
  ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to suppress creation of
    IP6 routes
  ipv6 addrconf: don't cleanup prefix route for IFA_F_NOPREFIXROUTE

 include/uapi/linux/if_addr.h |   1 +
 net/ipv6/addrconf.c          | 204 ++++++++++++++++++++++++++-----------------
 2 files changed, 123 insertions(+), 82 deletions(-)

-- 
1.8.4.2
