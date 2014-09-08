From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/2] net: systemport and bcmgenet OOM fixes
Date: Mon,  8 Sep 2014 11:37:50 -0700
Message-ID: <1410201472-3764-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:63094 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752994AbaIHSiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 14:38:02 -0400
Received: by mail-pa0-f44.google.com with SMTP id kx10so3667103pab.3
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 11:38:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

These two patches fix similar Out of Memory code paths in the SYSTEMPORT and
GENET drivers. Under high memory pressure, we could produce an OOPS by
passing a NULL pointer to dma_unmap_single().

Thanks!

Florian Fainelli (2):
  net: systemport: check harder for out of memory conditions
  net: bcmgenet: check harder for out of memory conditions

 drivers/net/ethernet/broadcom/bcmsysport.c     | 31 ++++++++++++++----------
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 33 +++++++++++++++-----------
 2 files changed, 38 insertions(+), 26 deletions(-)

-- 
1.9.1
