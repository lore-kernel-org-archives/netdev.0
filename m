From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net 0/4] Fixes for sh_eth #2
Date: Thu, 22 Jan 2015 12:38:04 +0000
Message-ID: <1421930284.1222.285.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: "David S.Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:40495 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbbAVMiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 07:38:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm continuing review and testing of Ethernet support on the R-Car H2
chip.  This series fixes more of the issues I've found, but it won't be
the last set.

These are not tested on any of the other supported chips.

Ben.

Ben Hutchings (4):
  sh_eth: Fix padding of short frames on TX
  sh_eth: Detach net device when stopping queue to resize DMA rings
  sh_eth: Fix crash or memory leak when resizing rings on device that
    is down
  sh_eth: Fix serialisation of interrupt disable with interrupt & NAPI
    handlers

 drivers/net/ethernet/renesas/sh_eth.c |   84 +++++++++++++++++++++------------
 drivers/net/ethernet/renesas/sh_eth.h |    1 +
 2 files changed, 55 insertions(+), 30 deletions(-)

-- 
1.7.10.4
