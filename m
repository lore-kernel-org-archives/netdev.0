From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 1/3] ethtool: Add phy statistics
Date: Tue, 29 Dec 2015 15:12:02 -0500 (EST)
Message-ID: <20151229.151202.766585486801107901.davem@davemloft.net>
References: <1451418684-9238-1-git-send-email-andrew@lunn.ch>
	<1451418684-9238-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59888 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753661AbbL2UMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 15:12:03 -0500
In-Reply-To: <1451418684-9238-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 29 Dec 2015 20:51:22 +0100

> @@ -191,6 +191,23 @@ static int ethtool_set_features(struct net_device *dev, void __user *useraddr)
>  	return ret;
>  }
>  
> +int phy_get_sset_count(struct phy_device *phydev)
> +{

This needs to be static.
