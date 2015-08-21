From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] phylib: Make PHYs children of their MDIO bus, not the
 bus' parent.
Date: Fri, 21 Aug 2015 16:59:45 -0700
Message-ID: <55D7BB71.6020601@gmail.com>
References: <1440198963-20080-1-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Daney <david.daney@cavium.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Grant Likely <grant.likely@secretlab.ca>
To: David Daney <ddaney.cavm@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:34692 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859AbbHVACQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 20:02:16 -0400
In-Reply-To: <1440198963-20080-1-git-send-email-ddaney.cavm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/08/15 16:16, David Daney wrote:
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

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
