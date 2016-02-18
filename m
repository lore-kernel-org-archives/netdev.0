From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next v3 0/3] IPvlan misc patches
Date: Wed, 17 Feb 2016 19:52:18 -0800
Message-ID: <1455767538-16667-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36625 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423667AbcBRDwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 22:52:30 -0500
Received: by mail-pf0-f194.google.com with SMTP id e127so1527310pfe.3
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 19:52:29 -0800 (PST)
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

 drivers/net/ipvlan/ipvlan.h      | 10 +++-------
 drivers/net/ipvlan/ipvlan_core.c | 31 ++++++++++++++++++-------------
 drivers/net/ipvlan/ipvlan_main.c | 11 +++++++----
 3 files changed, 28 insertions(+), 24 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
