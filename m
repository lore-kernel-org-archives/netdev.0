From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: dnet: use phydev from struct
 net_device
Date: Tue, 28 Jun 2016 05:10:58 -0400 (EDT)
Message-ID: <20160628.051058.2147077763062976982.davem@davemloft.net>
References: <1466718539-6526-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53794 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440AbcF1JMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 05:12:15 -0400
In-Reply-To: <1466718539-6526-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Thu, 23 Jun 2016 23:48:58 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
