From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy/micrel: change phy_id_mask for KSZ9021 and KS8001
Date: Tue, 19 Jun 2012 00:31:57 -0700 (PDT)
Message-ID: <20120619.003157.1182913417516661199.davem@davemloft.net>
References: <1340009529-4231-1-git-send-email-jason77.wang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.choi@micrel.com, nobuhiro.iwamatsu.yj@renesas.com,
	netdev@vger.kernel.org
To: jason77.wang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878Ab2FSHcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 03:32:00 -0400
In-Reply-To: <1340009529-4231-1-git-send-email-jason77.wang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hui Wang <jason77.wang@gmail.com>
Date: Mon, 18 Jun 2012 16:52:09 +0800

> On a freescale imx6q platform, a hardware phy chip KSZ9021 is
> recognized as a KS8001 chip by the current driver like this:
> eth0: Freescale FEC PHY driver [Micrel KS8001 or KS8721]
> 
> KSZ9021 has phy_id 0x00221610, while KSZ8001 has phy_id
> 0x0022161a, the current phy_id_mask (0x00fffff0/0x00ffff10) can't
> distinguish them. So change phy_id_mask to resolve this problem.
> 
> Although the micrel datasheet says that the 4 LSB of phyid2 register
> contains the chip revision number and the current driver is designed
> to follow this rule, in reality the chip implementation doesn't follow
> it.
> 
> Cc: David J. Choi <david.choi@micrel.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> Signed-off-by: Hui Wang <jason77.wang@gmail.com>

Applied, thanks.
