From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: dsa: Unregister slave_dev in error path
Date: Wed, 17 Feb 2016 22:05:47 -0500 (EST)
Message-ID: <20160217.220547.341101768991563084.davem@davemloft.net>
References: <1455761951-26408-1-git-send-email-f.fainelli@gmail.com>
	<1455763402-4399-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, opendmb@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33431 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424050AbcBRDFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 22:05:50 -0500
In-Reply-To: <1455763402-4399-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 17 Feb 2016 18:43:22 -0800

> With commit 0071f56e46da ("dsa: Register netdev before phy"), we are now trying
> to free a network device that has been previously registered, and in case of
> errors, this will make us hit the BUG_ON(dev->reg_state != NETREG_UNREGISTERED)
> condition.
> 
> Fix this by adding a missing unregister_netdev() before free_netdev().
> 
> Fixes: 0071f56e46da ("dsa: Register netdev before phy")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
