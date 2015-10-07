From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: remove link polling
Date: Wed, 07 Oct 2015 02:59:07 -0700 (PDT)
Message-ID: <20151007.025907.365366822224236229.davem@davemloft.net>
References: <E1ZiQIv-0003pw-Ur@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, linux@roeck-us.net
To: rmk+kernel@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbbJGJnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 05:43:25 -0400
In-Reply-To: <E1ZiQIv-0003pw-Ur@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@arm.linux.org.uk>
Date: Sat, 03 Oct 2015 18:09:01 +0100

> The link status is polled by the generic phy layer, there's no need to
> duplicate that polling with additional polling.  This additional polling
> adds additional MDIO traffic, and races with the generic phy layer,
> resulting in missing or duplicated link status messages.
> 
> Tested-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Applied.
