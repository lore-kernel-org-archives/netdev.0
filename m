From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/3] net: systemport: misc. improvements
Date: Fri, 29 May 2015 09:42:14 -0700
Message-ID: <1432917737-16793-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:33885 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756944AbbE2QuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 12:50:09 -0400
Received: by pdbki1 with SMTP id ki1so57590820pdb.1
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 09:50:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

These patches are highly inspired by changes from Petri on bcmgenet, last patch
is a misc fix that I had pending for a while, but is not a candidate for 'net'
at this point.

Changes in v2:

- added Petri's reviewed-by tag for patches 1 and 2
- reworked patch 2 to remove a now stale comment and use an unlikely optimization

Thanks!

Florian Fainelli (3):
  net: systemport: Pre-calculate and utilize cb->bd_addr
  net: systemport: rewrite bcm_sysport_rx_refill
  net: systemport: Add a check for oversized packets

 drivers/net/ethernet/broadcom/bcmsysport.c | 113 +++++++++++++++--------------
 drivers/net/ethernet/broadcom/bcmsysport.h |   2 -
 2 files changed, 58 insertions(+), 57 deletions(-)

-- 
2.1.0
