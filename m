From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: bcmgenet: Interrupt coalescing
Date: Wed, 16 Sep 2015 16:47:38 -0700
Message-ID: <1442447260-14129-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
	jaedon.shin@gmail.com, pgynther@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34282 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556AbbIPXvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 19:51:23 -0400
Received: by padhy16 with SMTP id hy16so2211286pad.1
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2015 16:51:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Petri, Jaedon,

This patch series adds support for interrupt coalescing for GENET adapters.

Florian Fainelli (2):
  net: bcmgenet: Implement TX coalescing control knobs
  net: bcmgenet: Implement RX coalescing control knobs

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 150 +++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |   9 +-
 2 files changed, 154 insertions(+), 5 deletions(-)

-- 
2.1.0
