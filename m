From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next 0/5] sh_eth changes for net-next
Date: Thu, 26 Feb 2015 20:31:05 +0000
Message-ID: <1424982665.4444.70.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:46668 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483AbbBZUbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 15:31:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some minor new features and fixes.

These depend in part on the series I sent earlier for net, specifically
"sh_eth: WARN on access to a register not implemented in a particular
chip" depends on "sh_eth: Fix RX recovery on R-Car in case of RX ring
underrun".

Ben.

Ben Hutchings (5):
  sh_eth: Implement multicast statistic based on the RFS8 status bit
  sh_eth: WARN on access to a register not implemented in a particular
    chip
  sh_eth: Implement ethtool register dump operations
  sh_eth: Optionally log RX and TX status for each completed descriptor
  sh_eth: Mitigate lost statistics updates

 drivers/net/ethernet/renesas/sh_eth.c |  259 ++++++++++++++++++++++++++++++---
 drivers/net/ethernet/renesas/sh_eth.h |   23 ++-
 2 files changed, 256 insertions(+), 26 deletions(-)

-- 
1.7.10.4
