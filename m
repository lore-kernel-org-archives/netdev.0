From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/2] net: bcmgenet and systemport statistics fixes
Date: Sat, 28 Feb 2015 18:09:15 -0800
Message-ID: <1425175757-13378-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:36470 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335AbbCACJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 21:09:33 -0500
Received: by pdbnh10 with SMTP id nh10so6791503pdb.3
        for <netdev@vger.kernel.org>; Sat, 28 Feb 2015 18:09:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This two patches fix a similar problem in the GENET and SYSTEMPORT drivers
for software maintained statistics used to track DMA mapping and SKB
re-allocation failures.

Thanks!

Florian Fainelli (2):
  net: bcmgenet: fix software maintained statistics
  net: systemport: fix software maintained statistics

 drivers/net/ethernet/broadcom/bcmsysport.c     |    7 ++++---
 drivers/net/ethernet/broadcom/bcmsysport.h     |    2 ++
 drivers/net/ethernet/broadcom/genet/bcmgenet.c |    9 ++++++---
 3 files changed, 12 insertions(+), 6 deletions(-)
