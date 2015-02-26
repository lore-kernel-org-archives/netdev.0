From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net 0/4] Fixes for sh_eth #4
Date: Thu, 26 Feb 2015 14:12:17 +0000
Message-ID: <1424959937.4444.12.camel@xylophone.i.decadent.org.uk>
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
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:34570 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259AbbBZOMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 09:12:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm continuing review and testing of Ethernet support on the R-Car H2
chip, with help from a colleague.  This series fixes a few more issues.

These are not tested on any of the other supported chips.

Ben.

Ben Hutchings (4):
  sh_eth: Ensure proper ordering of descriptor active bit write/read
  sh_eth: Fix RX recovery on R-Car in case of RX ring underrun
  Revert "sh_eth: Enable Rx descriptor word 0 shift for r8a7790"
  sh_eth: Really fix padding of short frames on TX

 drivers/net/ethernet/renesas/sh_eth.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

-- 
1.7.10.4
