From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 0/3] Minor IPv4 routing cleanups
Date: Mon, 28 Sep 2015 11:10:25 -0700
Message-ID: <20150928175512.20320.97537.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:32802 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754178AbbI1SK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 14:10:27 -0400
Received: by pacex6 with SMTP id ex6so180839322pac.0
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 11:10:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches just contain some minor cleanups to address a few minor
issues.  The first and the third mostly just improve readability.  The
second patch should improve the performance for multicast destination
addresses that do not have a localhost source IP address by avoiding some
unnecessary dereferences.

---

Alexander Duyck (2):
      net/ipv4: Pass proto as u8 instead of u16 in ip_check_mc_rcu
      net: Swap ordering of tests in ip_route_input_mc

David Ahern (1):
      net: Remove martian_source_keep_err goto label


 include/linux/igmp.h |    2 +-
 net/ipv4/igmp.c      |    2 +-
 net/ipv4/route.c     |   11 ++++-------
 3 files changed, 6 insertions(+), 9 deletions(-)

--
