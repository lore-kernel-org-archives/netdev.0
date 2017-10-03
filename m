From: Razvan Stefanescu <razvan.stefanescu@nxp.com>
Subject: RE: [PATCH v2 3/6] staging: fsl-dpaa2/ethsw: Add ethtool support
Date: Tue, 3 Oct 2017 05:22:06 +0000
Message-ID: <AM3PR04MB074387851364E6F24ECF4502E6720@AM3PR04MB0743.eurprd04.prod.outlook.com>
References: <1506933380-12641-1-git-send-email-razvan.stefanescu@nxp.com>
 <1506933380-12641-4-git-send-email-razvan.stefanescu@nxp.com>
 <20171002153718.GJ17713@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
 "arnd@arndb.de" <arnd@arndb.de>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 Alexandru Marginean <alexandru.marginean@nxp.com>,
 "agraf@suse.de" <agraf@suse.de>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "stuyoder@gmail.com" <stuyoder@gmail.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Bogdan Purcareata <bogdan.purcareata@nxp.com>,
 Laurentiu Tudor <laurentiu.tudor@nxp.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20171002153718.GJ17713@lunn.ch>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Monday, October 02, 2017 18:37
> To: Razvan Stefanescu <razvan.stefanescu@nxp.com>
> Cc: gregkh@linuxfoundation.org; devel@driverdev.osuosl.org; linux-
> kernel@vger.kernel.org; netdev@vger.kernel.org; agraf@suse.de;
> arnd@arndb.de; Alexandru Marginean <alexandru.marginean@nxp.com>;
> Bogdan Purcareata <bogdan.purcareata@nxp.com>; Ruxandra Ioana Radulescu
> <ruxandra.radulescu@nxp.com>; Laurentiu Tudor <laurentiu.tudor@nxp.com>;
> stuyoder@gmail.com
> Subject: Re: [PATCH v2 3/6] staging: fsl-dpaa2/ethsw: Add ethtool support
> 
> Hi Razvan
> 
> > +static void ethsw_get_drvinfo(struct net_device *netdev,
> > +			      struct ethtool_drvinfo *drvinfo)
> > +{
> > +	struct ethsw_port_priv *port_priv = netdev_priv(netdev);
> > +	u16 version_major, version_minor;
> > +	int err;
> > +
> > +	strlcpy(drvinfo->driver, KBUILD_MODNAME, sizeof(drvinfo->driver));
> > +	strlcpy(drvinfo->version, ethsw_drv_version, sizeof(drvinfo->version));
> 
> Software driver versions are mostly useless. I would suggest you
> remove this.
> 
>        Andrew
Thank you. I'll remove it in v3.

Best regards,
Razvan S.
