From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next 0/3] net: bcmgenet: code cleanup
Date: Fri, 27 Mar 2015 22:50:33 -0700 (PDT)
Message-ID: <20150328055034.10049220209@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:32800 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbbC1Fuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2015 01:50:35 -0400
Received: by pablj1 with SMTP id lj1so8280247pab.0
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 22:50:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Three patches to clean up bcmgenet code:
1. add UMAC_IRQ_RXDMA_DONE and UMAC_IRQ_TXDMA_DONE
2. remove __bcmgenet_fini_dma()
3. fix bcmgenet_open()
