From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: tc35815: use phydev from struct
 net_device
Date: Fri, 15 Jul 2016 16:42:58 -0700 (PDT)
Message-ID: <20160715.164258.1598018345122121631.davem@davemloft.net>
References: <1468502447-2254-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, linux@roeck-us.net, colin.king@canonical.com,
	f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56482 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbcGOXnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 19:43:03 -0400
In-Reply-To: <1468502447-2254-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Thu, 14 Jul 2016 15:20:46 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phy in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
