From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next v4 0/3] IPvlan misc patches
Date: Sat, 20 Feb 2016 19:31:22 -0800
Message-ID: <1456025482-30203-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36650 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbcBUSzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 13:55:32 -0500
Received: by mail-pf0-f195.google.com with SMTP id e127so6169505pfe.3
        for <netdev@vger.kernel.org>; Sun, 21 Feb 2016 10:55:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

This is a collection of unrelated patches for IPvlan driver.
a. crub_skb() changes are added to ensure that the packets hit the
NF_HOOKS in masters' ns in L3 mode.
b. u16 change is bug fix while
c. the third patch is to group tx/rx variables in single cacheline

Mahesh Bandewar (3):
  ipvlan: scrub skb before routing in L3 mode.
  ipvlan: mode is u16
  ipvlan: misc changes

 drivers/net/ipvlan/ipvlan.h      | 10 +++------
 drivers/net/ipvlan/ipvlan_core.c | 46 +++++++++++++++++++++++-----------------
 drivers/net/ipvlan/ipvlan_main.c | 11 ++++++----
 3 files changed, 36 insertions(+), 31 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
