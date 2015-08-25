From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: Make PHYs children of their MDIO bus, not the
 bus' parent.
Date: Tue, 25 Aug 2015 11:31:36 -0700 (PDT)
Message-ID: <20150825.113136.806044696899448612.davem@davemloft.net>
References: <1440198963-20080-1-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	f.fainelli@gmail.com, david.daney@cavium.com,
	buytenh@wantstofly.org, grant.likely@secretlab.ca
To: ddaney.cavm@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58743 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755732AbbHYSbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 14:31:37 -0400
In-Reply-To: <1440198963-20080-1-git-send-email-ddaney.cavm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <ddaney.cavm@gmail.com>
Date: Fri, 21 Aug 2015 16:16:03 -0700

> From: David Daney <david.daney@cavium.com>
> 
> commit 18ee49ddb0d2 ("phylib: rename mii_bus::dev to mii_bus::parent")
> changed the parent of PHY devices from the bus to the bus parent.
> 
> Then, commit 4dea547fef1b ("phylib: rework to prepare for OF
> registration of PHYs") moved the code into phy_device.c
> 
> At this point, it is somewhat unclear why the change was seen as
> necessary.  But, when we look at the device model tree in
> /sys/devices, it is clearly incorrect.  The PHYs should be children of
> their MDIO bus.
> 
> Change the PHY's parent device to be the MDIO bus device.
> 
> Cc: Lennert Buytenhek <buytenh@wantstofly.org>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Signed-off-by: David Daney <david.daney@cavium.com>

Applied, thanks.
