From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 0/5] net: Refactor inetpeer cache and add support for VRFs
Date: Thu, 27 Aug 2015 14:16:28 -0700
Message-ID: <1440710193-4824-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36315 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751367AbbH0VR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 17:17:56 -0400
Received: by pacgr6 with SMTP id gr6so1014626pac.3
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 14:17:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Per Dave's comment on the version 1 patch adding VRF support to inetpeer
cache by explicitly making the address + index a key. Refactored the
inetpeer code in the process.

David Ahern (5):
  net: Introduce ipv4_addr_hash and use it for tcp metrics
  net: Add set,get helpers for inetpeer addresses
  net: Add helper function to compare inetpeer addresses
  net: Refactor inetpeer address struct
  net: Add support for VRFs to inetpeer cache

 include/net/inetpeer.h | 64 ++++++++++++++++++++++++++++++++-------
 include/net/ip.h       |  5 ++++
 net/ipv4/icmp.c        |  3 +-
 net/ipv4/inetpeer.c    | 20 ++-----------
 net/ipv4/ip_fragment.c |  3 +-
 net/ipv4/route.c       |  7 +++--
 net/ipv4/tcp_metrics.c | 81 ++++++++++++++++++++------------------------------
 7 files changed, 103 insertions(+), 80 deletions(-)

-- 
1.9.1
