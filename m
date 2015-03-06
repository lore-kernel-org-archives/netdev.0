From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next 0/3] net: bcmgenet: preparation for multiple Rx queues
Date: Thu,  5 Mar 2015 17:40:08 -0800 (PST)
Message-ID: <20150306014008.DDA6C2214B6@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f201.google.com ([209.85.213.201]:32922 "EHLO
	mail-ig0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbbCFBkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 20:40:10 -0500
Received: by igkb16 with SMTP id b16so110956igk.0
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 17:40:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Three small patches in preparation for supporting multiple Rx queues:
1. set hw_params->rx_queues = 0
2. adjust the call to alloc_etherdev_mqs()
3. add GENET_Q16_RX_BD_CNT and hw_params->rx_bds_per_q
