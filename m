From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: dsa: add includes for ethtool and
 phy_fixed definitions
Date: Fri, 17 Oct 2014 23:55:07 -0400 (EDT)
Message-ID: <20141017.235507.1086741239870702753.davem@davemloft.net>
References: <1413586933-12090-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44391 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509AbaJRDzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 23:55:09 -0400
In-Reply-To: <1413586933-12090-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 17 Oct 2014 16:02:13 -0700

> net/dsa/slave.c uses functions and structures declared in phy_fixed.h
> but does not explicitely include it, while dsa.h needs structure
> declarations for 'struct ethtool_wolinfo' and 'struct ethtool_eee', fix
> those by including the correct header files.
> 
> Fixes: ec9436baedb6 ("net: dsa: allow drivers to do link adjustment")
> Fixes: ce31b31c68e7 ("net: dsa: allow updating fixed PHY link information")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
