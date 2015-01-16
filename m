From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net 0/2] sh_eth fixes
Date: Fri, 16 Jan 2015 17:49:52 +0000
Message-ID: <1421430592.1222.190.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:47060 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbbAPRt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 12:49:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm currently looking at Ethernet support on the R-Car H2 chip,
reviewing and testing the sh_eth driver.  Here are fixes for two fairly
obvious bugs in the driver; I will probably have some more later.

These are not tested on any of the other supported chips.

Ben.

Ben Hutchings (2):
  sh_eth: Fix promiscuous mode on chips without TSU
  sh_eth: Fix ethtool operation crash when net device is down

 drivers/net/ethernet/renesas/sh_eth.c |   28 +++++++++++++++++++---------
 1 file changed, 19 insertions(+), 9 deletions(-)

-- 
1.7.10.4
