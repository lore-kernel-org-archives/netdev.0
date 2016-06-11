From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: smsc: reintroduced unconditional soft reset
Date: Fri, 10 Jun 2016 22:15:20 -0700 (PDT)
Message-ID: <20160610.221520.1860652774061910506.davem@davemloft.net>
References: <575538B3.8030406@ginzinger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gwenhael.goavec-merou@armadeus.com,
	manfred.schlaegl@gmx.at
To: manfred.schlaegl@ginzinger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34864 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280AbcFKFPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 01:15:21 -0400
In-Reply-To: <575538B3.8030406@ginzinger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manfred Schlaegl <manfred.schlaegl@ginzinger.com>
Date: Mon, 6 Jun 2016 10:47:47 +0200

> We detected some problems using the smsc lan8720a in combination with
> i.MX28 and tracked this down to commit 21009686662f ("net: phy: smsc: move
> smsc_phy_config_init reset part in a soft_reset function")
> With 2100968666 the generic soft reset is replaced by a specific function
> which handles power down state correctly. But additionally the soft reset
> itself got conditional and is therefore also only performed if the phy is
> in power down state.
> 
> This patch keeps the conditional wake up from power down, but
> re-introduces the unconditional soft reset using the generic soft reset
> function.
> It was tested on linux-4.1.25 and linux-4.7.0-rc2.
> 
> Signed-off-by: Manfred Schlaegl <manfred.schlaegl@ginzinger.com>

Applied.
