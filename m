From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: dwc_eth_qos: use phydev from struct
 net_device
Date: Tue, 28 Jun 2016 09:20:06 -0400 (EDT)
Message-ID: <20160628.092006.2231420904636974389.davem@davemloft.net>
References: <1466888716-31222-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56792 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226AbcF1NUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 09:20:37 -0400
In-Reply-To: <1466888716-31222-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat, 25 Jun 2016 23:05:15 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
