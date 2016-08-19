From: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>
Subject: RE: [PATCH 1/2] net: phy: Add error checks in the driver
Date: Fri, 19 Aug 2016 13:18:12 +0000
Message-ID: <C246CAC1457055469EF09E3A7AC4E11A4A5E4A7C@XAP-PVEXMBX01.xlnx.xilinx.com>
References: <1471610891-13353-1-git-send-email-appanad@xilinx.com>
 <20160819131517.GB7343@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Michal Simek <michals@xilinx.com>, Soren Brinkmann <sorenb@xilinx.com>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20160819131517.GB7343@lunn.ch>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

	Thanks for the review...

> > -	mdiobus_write(phydev->mdio.bus, priv->addr,
> XILINX_GMII2RGMII_REG, val);
> > +	err = mdiobus_write(phydev->mdio.bus, priv->addr,
> XILINX_GMII2RGMII_REG,
> > +			    val);
> > +	if (err < 0)
> > +		return err;
> >
> >  	return 0;
> 
> Do you need to assign err? Why not just

Ok will fix in the next version....

Regards,
Kedar.

> 
>    return mdiobus_write(phydev->mdio.bus, priv->addr,
> XILINX_GMII2RGMII_REG,
> 			val);
