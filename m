From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: systemport: tell RXCHK if we are using
 Broadcom tags
Date: Mon, 01 Sep 2014 18:12:59 -0700 (PDT)
Message-ID: <20140901.181259.1117890090821962038.davem@davemloft.net>
References: <1409263863-5364-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45869 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162AbaIBBNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 21:13:00 -0400
In-Reply-To: <1409263863-5364-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 28 Aug 2014 15:11:03 -0700

> When Broadcom tags are enabled, e.g: when interfaced to an Ethernet
> switch, make sure that we tell the RXCHK engine that it should be
> expecting a 4-bytes Broadcom tag after the Ethernet MAC Source Address.
> 
> Use netdev_uses_dsa() to check for that condition since that will tell
> us if a switch is attached to our network interface.
> 
> Fixes: 80105befdb4b ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
