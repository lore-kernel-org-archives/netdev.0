From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH kernel 0/4] Fixes for sh_eth #3
Date: Tue, 27 Jan 2015 00:40:32 +0000
Message-ID: <1422319232.3524.14.camel@xylophone.i.decadent.org.uk>
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
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:49923 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752345AbbA0Akb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 19:40:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm continuing review and testing of Ethernet support on the R-Car H2
chip.  This series fixes the last of the more serious issues I've found.

These are not tested on any of the other supported chips.

Ben.

Ben Hutchings (4):
  sh_eth: Remove RX overflow log messages
  sh_eth: Ensure DMA engines are stopped before freeing buffers
  sh_eth: Check for DMA mapping errors on transmit
  sh_eth: Fix DMA-API usage for RX buffers

 drivers/net/ethernet/renesas/sh_eth.c |   80 ++++++++++++++++++++++++---------
 1 file changed, 59 insertions(+), 21 deletions(-)

-- 
1.7.10.4
