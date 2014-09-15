From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: fix mii_bus to host_dev replacement
Date: Mon, 15 Sep 2014 17:53:07 -0400 (EDT)
Message-ID: <20140915.175307.1827241519601268625.davem@davemloft.net>
References: <1410817688-19397-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40440 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755624AbaIOVxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:53:09 -0400
In-Reply-To: <1410817688-19397-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 15 Sep 2014 14:48:08 -0700

> dsa_of_probe() still used cd->mii_bus instead of cd->host_dev when
> building with CONFIG_OF=y. Fix this by making the replacement here as
> well.
> 
> Fixes: b4d2394d01b ("dsa: Replace mii_bus with a generic host device")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks for catching this.
