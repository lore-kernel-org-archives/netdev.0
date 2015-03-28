From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 0/4 v2] ipvlan: list corruption and rcu fixes
Date: Sat, 28 Mar 2015 19:13:21 +0100
Message-ID: <cover.1427566140.git.jbenc@redhat.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Dan Williams <dcbw@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42454 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751016AbbC1SNj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Mar 2015 14:13:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set fixes different issues leading to corrupted lists and
incorrect rcu usage.

Only patch 1/4 changed since the last submission.

Jiri Benc (4):
  ipvlan: fix addr hash list corruption
  ipvlan: protect against concurrent link removal
  ipvlan: do not use rcu operations for address list
  ipvlan: fix check for IP addresses in control path

 drivers/net/ipvlan/ipvlan.h      |  4 +++-
 drivers/net/ipvlan/ipvlan_core.c | 28 ++++++++++++++++++++--------
 drivers/net/ipvlan/ipvlan_main.c | 30 +++++++++++++++++++-----------
 3 files changed, 42 insertions(+), 20 deletions(-)

-- 
1.8.3.1
