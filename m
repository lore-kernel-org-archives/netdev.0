From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next 0/5] net: updates for IPv6 Segment Routing
Date: Wed, 23 Aug 2017 17:31:58 +0200
Message-ID: <20170823153203.11951-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:40409 "EHLO
        smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754129AbdHWPbx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 11:31:53 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp4.sgsi.ucl.ac.be (Postfix) with ESMTPS id E0BB567DA0F
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 17:31:42 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series provides several updates for the SRv6 implementation. The
first patch leverages the existing infrastructure to support encapsulation
of IPv4 packets. The second patch implements the T.Encaps.L2 SR function,
enabling to encapsulate an L2 Ethernet frame within an IPv6+SRH packet.
The last three patches update the seg6local lightweight tunnel, and mainly
implement four new actions: End.T, End.DX2, End.DX4 and End.DT6.

David Lebrun (5):
  ipv6: sr: add support for ip4ip6 encapsulation
  ipv6: sr: add support for encapsulation of L2 frames
  ipv6: sr: enforce IPv6 packets for seg6local lwt
  ipv6: sr: add helper functions for seg6local
  ipv6: sr: implement additional seg6local actions

 include/net/seg6.h                 |   3 +-
 include/uapi/linux/seg6_iptunnel.h |  19 ++-
 net/ipv6/Kconfig                   |   1 +
 net/ipv6/seg6_iptunnel.c           |  65 ++++++--
 net/ipv6/seg6_local.c              | 314 ++++++++++++++++++++++++++++---------
 5 files changed, 313 insertions(+), 89 deletions(-)

-- 
2.10.2
