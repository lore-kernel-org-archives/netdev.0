From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v2 net 0/2] Alow tg3/bnx recevie full sized 802.1ad frames
Date: Tue, 30 Sep 2014 19:39:35 -0400
Message-ID: <1412120377-11125-1-git-send-email-vyasevic@redhat.com>
Cc: prashant@broadcom.com, mchan@broadcom.com, sony.chacko@qlogic.com,
	Dept-HSGLinuxNICDev@qlogic.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:43019 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbaI3Xjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 19:39:46 -0400
Received: by mail-qc0-f172.google.com with SMTP id o8so39318qcw.31
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 16:39:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2 and tg3 drivers drop packets that exceed device mtu and that
do not have a vlan tag.  The idea is to catch ethernet frames
that are too long.  This also ends up dropping 802.1ad tagged
frames since the encapsulation protocol is different.
We should not be dropping this packets.

v2:  rebased and consolidated tg3 and bnx patches.

Vladislav Yasevich (2):
  tg3: Allow for recieve of full-size 8021AD frames
  bnx2: Correctly receive full sized 802.1ad fragmes

 drivers/net/ethernet/broadcom/bnx2.c | 5 +++--
 drivers/net/ethernet/broadcom/tg3.c  | 3 ++-
 2 files changed, 5 insertions(+), 3 deletions(-)

-- 
1.9.3
