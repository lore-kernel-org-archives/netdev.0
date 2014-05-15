From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v5 0/2] net: systemport: couples fixes
Date: Wed, 14 May 2014 19:32:12 -0700
Message-ID: <1400121134-6088-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, David Laight <David.Laight@aculab.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:56022 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077AbaEOCc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 22:32:29 -0400
Received: by mail-pb0-f41.google.com with SMTP id uo5so423367pbc.28
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 19:32:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David(s),

This fifth version should hopefully explain it all!

Thanks

Florian Fainelli (2):
  net: systemport: only update UMAC_CMD if something changed
  net: systemport: pad packets to a minimum of 68 bytes

 drivers/net/ethernet/broadcom/bcmsysport.c | 35 ++++++++++++++++++++++--------
 drivers/net/ethernet/broadcom/bcmsysport.h |  6 ++---
 2 files changed, 29 insertions(+), 12 deletions(-)

-- 
1.9.1
