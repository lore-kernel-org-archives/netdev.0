From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Don't reset PHY on if_up for ASIX 88772
Date: Fri, 03 Oct 2014 15:39:27 -0700 (PDT)
Message-ID: <20141003.153927.1271451328252985749.davem@davemloft.net>
References: <1412238122-1914-1-git-send-email-m.stam@fugro.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, freddy@asix.com.tw, grundler@chromium.org
To: m.stam@fugro.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60371 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753166AbaJCWhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:37:21 -0400
In-Reply-To: <1412238122-1914-1-git-send-email-m.stam@fugro.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michel Stam <m.stam@fugro.nl>
Date: Thu,  2 Oct 2014 10:22:02 +0200

> I've noticed every time the interface is set to 'up,', the kernel
> reports that the link speed is set to 100 Mbps/Full Duplex, even
> when ethtool is used to set autonegotiation to 'off', half
> duplex, 10 Mbps.
> It can be tested by:
>  ifconfig eth0 down
>  ethtool -s eth0 autoneg off speed 10 duplex half
>  ifconfig eth0 up
> 
> Then checking 'dmesg' for the link speed.
> 
> Signed-off-by: Michel Stam <m.stam@fugro.nl>

Applied, thank you.
