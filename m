From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v1 0/7] net: phy: Ethernet PHY powerdown
 optimization
Date: Wed, 20 Nov 2013 17:15:25 -0500 (EST)
Message-ID: <20131120.171525.1584609970007162599.davem@davemloft.net>
References: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com>
	<20131120.153642.2045230991917379052.davem@davemloft.net>
	<528D217B.5020500@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37412 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752146Ab3KTWP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 17:15:29 -0500
In-Reply-To: <528D217B.5020500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Date: Wed, 20 Nov 2013 21:54:19 +0100

> Right, as far as I understand BMCR powerdown, i.e. what is called in
> genphy_suspend/resume, powers down the PHY but _does_ retain PHY
> config.
> It is not resetting the device.
> 
> I haven't checked a lot of datasheets but [1] notes that "registers
> will
> preserve their configuration". Even if we have PHYs that do not
> preserve
> it, they should have a device specific callback for suspend/resume
> that
> takes care of preserving it.
> 
> [1] http://www.ti.com/lit/an/snoa463a/snoa463a.pdf

Thanks, that addresses my concerns.
