From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: davinci_emac: use phydev from
 struct net_device
Date: Sat, 02 Jul 2016 14:51:35 -0400 (EDT)
Message-ID: <20160702.145135.1232707650536090102.davem@davemloft.net>
References: <1467410555-19514-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
	linux-omap@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [184.105.139.130] ([184.105.139.130]:37744 "EHLO
	shards.monkeyblade.net" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750800AbcGBSvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 14:51:43 -0400
In-Reply-To: <1467410555-19514-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat,  2 Jul 2016 00:02:34 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phy in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
