From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 3/3] ixgbe: add syfs interface for to export read
 only driver information
Date: Thu, 05 Apr 2012 20:59:42 -0400 (EDT)
Message-ID: <20120405.205942.91469949871612514.davem@davemloft.net>
References: <4F7D8DD4.5080205@openwrt.org>
	<1333643525.2652.10.camel@bwh-desktop.uk.solarflarecom.com>
	<81212BCD-D022-4B71-955A-96B6C8E2A5DC@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, florian@openwrt.org,
	jeffrey.t.kirsher@intel.com, donald.c.skidmore@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: mark.d.rustad@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33365 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752310Ab2DFA7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 20:59:52 -0400
In-Reply-To: <81212BCD-D022-4B71-955A-96B6C8E2A5DC@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Date: Thu, 5 Apr 2012 23:52:40 +0000

> The redundancy with ethtool doesn't bother me much, because I think
> sysfs is a more general way to export driver information, and I find
> it very convenient to get as much as is practical from a single
> source. I really like doing "grep . * */*" in sysfs and getting as
> much information as possible about a driver.

That's not our position, we have flexible, extensible, interfaces
such as ethtool and netlink so that people don't get the urge
to toss random unnecessary junk into sysfs.

There are no damn APIs for what driver guys want to put into
sysfs, making it terrible from a user's perspective.

Whereas ethtool and netlink give you something consistent and
reliable.

Therefore there will be hard pushback on anything one tries to
export via sysfs, it is almost guarenteed that ethtool and
netlink fit the bill properly.
 
