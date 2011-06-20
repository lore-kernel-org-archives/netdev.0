From: David Miller <davem@davemloft.net>
Subject: Re: [RFT PATCH 3/9] net: ethtool: break association of ETH_FLAG_*
 with NETIF_F_*
Date: Mon, 20 Jun 2011 13:52:24 -0700 (PDT)
Message-ID: <20110620.135224.1609394919600206157.davem@davemloft.net>
References: <51d2fd4cf6855c2285ca9bcd8d267abedcbc599c.1308596963.git.mirq-linux@rere.qmqm.pl>
	<1308600681.2701.159.camel@bwh-desktop>
	<20110620135109.63d81d83@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, mirq-linux@rere.qmqm.pl,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34845 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752901Ab1FTUwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 16:52:31 -0400
In-Reply-To: <20110620135109.63d81d83@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 20 Jun 2011 13:51:09 -0700

> I have no problem with dropping or changing the sysfs feature output.
> It is useful to have a way to check if device supports something.

These days that's not even where we store the "capabilities" of the
device.

That happens in ->hw_features now.
