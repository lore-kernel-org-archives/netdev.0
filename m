From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] net: phy: marvell: More hidden page
 changes refactored
Date: Thu, 25 May 2017 12:46:03 -0400 (EDT)
Message-ID: <20170525.124603.1937819669219575888.davem@davemloft.net>
References: <1495574697-501-1-git-send-email-andrew@lunn.ch>
        <1495574697-501-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59118 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942640AbdEYQqE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 12:46:04 -0400
In-Reply-To: <1495574697-501-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 23 May 2017 23:24:55 +0200

> EXT_ADDR_PAGE is the same meaning as MII_MARVELL_PHY_PAGE, i.e. change
> page. Replace it will calls to the helpers.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Sorry to ding you on this but...

> @@ -1556,12 +1552,19 @@ static int m88e1121_get_temp(struct phy_device *phydev, long *temp)
>  {
>  	int ret;
>  	int val;
> +	int oldpage;

Reverse christmas tree.

> @@ -1671,12 +1674,19 @@ static const struct hwmon_chip_info m88e1121_hwmon_chip_info = {
>  static int m88e1510_get_temp(struct phy_device *phydev, long *temp)
>  {
>  	int ret;
> +	int oldpage;
>  
>  	*temp = 0;

Likewise.

> @@ -1696,12 +1706,18 @@ static int m88e1510_get_temp(struct phy_device *phydev, long *temp)
>  int m88e1510_get_temp_critical(struct phy_device *phydev, long *temp)
>  {
>  	int ret;
> +	int oldpage;
>  
>  	*temp = 0;

Likewise.

> @@ -1724,10 +1740,17 @@ int m88e1510_get_temp_critical(struct phy_device *phydev, long *temp)
>  int m88e1510_set_temp_critical(struct phy_device *phydev, long temp)
>  {
>  	int ret;
> +	int oldpage;

Likewise.

> @@ -1751,12 +1774,19 @@ int m88e1510_set_temp_critical(struct phy_device *phydev, long temp)
>  int m88e1510_get_temp_alarm(struct phy_device *phydev, long *alarm)
>  {
>  	int ret;
> +	int oldpage;

Likewise.

Otherwise this patch series looks fine to me.

THanks.
