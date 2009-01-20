From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000e: drop lltx, remove unnecessary lock
Date: Mon, 19 Jan 2009 16:52:20 -0800 (PST)
Message-ID: <20090119.165220.120345185.davem@davemloft.net>
References: <20090120001708.22703.8019.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	donash4@gmail.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44884
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754045AbZATAwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 19:52:19 -0500
In-Reply-To: <20090120001708.22703.8019.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 19 Jan 2009 16:17:08 -0800

> LLTX is deprecated and complicated, don't use it.  It was observed by Don Ash
> <donash4@gmail.com> that e1000e was acquiring this lock in the NAPI cleanup
> path.  This is obviously a bug, as this is a leftover from when e1000
> supported multiple tx queues and fake netdevs.
> 
> another user reported this to us and tested routing with the 2.6.27 kernel and
> this patch and reported a 3.5 % improvement in packets forwarded in a
> multi-port test on 82571 parts.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Nice, applied.

One down, 16 to go.  The following drivers are on notice :-)

drivers/net/atl1e/atl1e_main.c
drivers/net/bonding/bond_main.c
drivers/net/chelsio/cxgb2.c
drivers/net/cris/eth_v10.c
drivers/net/cxgb3/cxgb3_main.c
drivers/net/e1000/e1000_main.c
drivers/net/ehea/ehea_main.c
drivers/net/ibmveth.c
drivers/net/igb/igb_main.c
drivers/net/loopback.c
drivers/net/pasemi_mac.c
drivers/net/rionet.c
drivers/net/spider_net.c
drivers/net/sungem.c
drivers/net/tehuti.c
drivers/net/veth.c
