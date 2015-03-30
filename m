From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next v2 0/5] net: bcmgenet: code cleanup
Date: Mon, 30 Mar 2015 00:28:34 -0700 (PDT)
Message-ID: <20150330072835.0E1EB220215@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f74.google.com ([209.85.218.74]:32793 "EHLO
	mail-oi0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740AbbC3H2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 03:28:36 -0400
Received: by oiax69 with SMTP id x69so3117785oia.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 00:28:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Five patches to clean up bcmgenet code:
1. add UMAC_IRQ_RXDMA_DONE and UMAC_IRQ_TXDMA_DONE
2. remove __bcmgenet_fini_dma()
3. fix bcmgenet_open()
4. add UMAC_IRQ_LINK_EVENT
5. fix the call to phy_mac_interrupt()
