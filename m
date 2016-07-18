From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: adi: bfin_mac: use phydev from
 struct net_device
Date: Sun, 17 Jul 2016 23:22:43 -0700 (PDT)
Message-ID: <20160717.232243.1739034397561532468.davem@davemloft.net>
References: <1468710615-31951-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, sudipm.mukherjee@gmail.com, mugunthanvnm@ti.com,
	felipe.balbi@linux.intel.com, treding@nvidia.com, fw@strlen.de,
	linux@roeck-us.net, adi-buildroot-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58584 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbcGRGWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 02:22:47 -0400
In-Reply-To: <1468710615-31951-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 17 Jul 2016 01:10:14 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
