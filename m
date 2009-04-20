From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/5] ixgbe: fix link down initial state
Date: Mon, 20 Apr 2009 02:04:59 -0700 (PDT)
Message-ID: <20090420.020459.262772235.davem@davemloft.net>
References: <20090418064427.4328.45811.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48951
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751293AbZDTJFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 05:05:07 -0400
In-Reply-To: <20090418064427.4328.45811.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 17 Apr 2009 23:44:27 -0700

> All the intel wired ethernet drivers were calling netif_carrier_off
> and netif_stop_queue (or variants) before calling register_netdevice
> 
> This is incorrect behavior as was pointed out by davem, and causes
> ifconfig and friends to report a strange state before first link
> after the driver was loaded, since without a netif_carrier_off, the stack
> assumes carrier_on, but before register_netdev, netlink messages are not
> sent out telling link state.

All 5 patches applied, thanks!

FWIW, this is definitely a case where I would have found it just as
appropriate to post one single patch for this.  But that's just me :-)
