From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 3/6] staging: fsl-dpaa2/ethsw: Add ethtool support
Date: Mon, 2 Oct 2017 17:37:18 +0200
Message-ID: <20171002153718.GJ17713@lunn.ch>
References: <1506933380-12641-1-git-send-email-razvan.stefanescu@nxp.com>
 <1506933380-12641-4-git-send-email-razvan.stefanescu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        agraf@suse.de, arnd@arndb.de, alexandru.marginean@nxp.com,
        bogdan.purcareata@nxp.com, ruxandra.radulescu@nxp.com,
        laurentiu.tudor@nxp.com, stuyoder@gmail.com
To: Razvan Stefanescu <razvan.stefanescu@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1506933380-12641-4-git-send-email-razvan.stefanescu@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Razvan

> +static void ethsw_get_drvinfo(struct net_device *netdev,
> +			      struct ethtool_drvinfo *drvinfo)
> +{
> +	struct ethsw_port_priv *port_priv = netdev_priv(netdev);
> +	u16 version_major, version_minor;
> +	int err;
> +
> +	strlcpy(drvinfo->driver, KBUILD_MODNAME, sizeof(drvinfo->driver));
> +	strlcpy(drvinfo->version, ethsw_drv_version, sizeof(drvinfo->version));

Software driver versions are mostly useless. I would suggest you
remove this.

       Andrew
