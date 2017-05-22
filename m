From: Blair Steven <blair.steven@alliedtelesis.co.nz>
Subject: [PATCH] H.245 ALG dropping packets
Date: Mon, 22 May 2017 14:07:52 +1200
Message-ID: <20170522020753.16712-1-blair.steven@alliedtelesis.co.nz>
Cc: Blair Steven <blair.steven@alliedtelesis.co.nz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:43336 "EHLO
        gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751344AbdEVCKZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 22:10:25 -0400
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (Client did not present a certificate)
        by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id 9F461806A8
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 14:10:18 +1200 (NZST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have a setup where two VoIP phones are communicating through a
router on a trusted LAN where the H.245 ALG is dropping some of the
traffic, so far as I can tell without good cause. These two devices
are configured differently, one with Fast Connect and one without -
this might be the reason, but from my (limited) understanding of ALGs
this isn't a good enough reason.

Does it ever make sense to drop packets in an ALG?

Blair Steven (1):
  Accept packets that the H.245 ALG can't process

 net/netfilter/nf_conntrack_h323_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

-- 
2.9.3
