From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: smsc: force all capable mode if the phy is
 started in powerdown mode
Date: Mon, 03 Dec 2012 13:34:45 -0500 (EST)
Message-ID: <20121203.133445.1850294260156519269.davem@davemloft.net>
References: <1354394689-28281-1-git-send-email-tremyfr@yahoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	otavio@ossystems.com.br, javier@dowhile0.org, jkosina@suse.cz,
	eric.jarrige@armadeus.org, julien.boibessot@armadeus.com,
	thomas.petazzoni@free-electrons.com
To: tremyfr@yahoo.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354394689-28281-1-git-send-email-tremyfr@yahoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@yahoo.fr>
Date: Sat,  1 Dec 2012 21:44:49 +0100

>  static int smsc_phy_config_init(struct phy_device *phydev)
>  {
> -	int rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
> +	/*
> +	 * If the SMSC PHY is in power down mode, then set it
> +	 * in all capable mode before using it.
> +	 */
> +	int rc = phy_read(phydev, MII_LAN83C185_SPECIAL_MODES);

This is formatted poorly.  Do not put comments above the basic
block variable declarations, it looks terrible.

Also, comments in the networking code should be formatted:

	/* Like
	 * this.
	 */

	/*
	 * Not like
	 * this.
	 */

Thanks.
