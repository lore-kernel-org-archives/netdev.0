From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 00/11] DMA sync errors
Date: Wed, 20 Jan 2010 12:44:59 -0800
Message-ID: <20100120204459.820265084@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:53912 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753659Ab0ATVWz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 16:22:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to the DMA-API.txt
  Synchronise a single contiguous or scatter/gather mapping.  All the
  parameters must be the same as those passed into the single mapping
  API.

Reviewed the following drivers with potentail for this problem;
those with - are ok, and the ones with + have a patch in this
series.

+ drivers/infiniband/ulp/ipoib/ipoib_cm.c
- drivers/message/fusion/mptlan.c
- drivers/net/b44.c
- drivers/net/bnx2.c
+ drivers/net/cassini.c
- drivers/net/chelsio/sge.c
+ drivers/net/cxgb3/sge.c
- drivers/net/irda/vlsi_ir.c
- drivers/net/myri_sbus.c
+ drivers/net/r8169.c
+ drivers/net/rrunner.c
+ drivers/net/skge.c
+ drivers/net/sky2.c
+ drivers/net/sungem.c
+ drivers/net/sunhme.c
+ drivers/net/tg3.c
- drivers/net/tokenring/3c359.c
- drivers/net/tokenring/olympic.c
+ drivers/net/tulip/de2104x.c
- drivers/net/via-velocity.c
- drivers/net/wireless/ipw2x00/ipw2100.c
- drivers/net/wireless/ipw2x00/ipw2200.c

