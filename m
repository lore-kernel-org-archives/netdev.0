From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next v2 12/12] net: dsa: mv88e6xxx: add addressing
 mode to info
Date: Tue, 14 Jun 2016 23:34:48 +0200
Message-ID: <20160614213448.GF12832@lunn.ch>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
 <20160614183153.32327-13-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46146 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751119AbcFNVev (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 17:34:51 -0400
Content-Disposition: inline
In-Reply-To: <20160614183153.32327-13-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -3681,7 +3681,7 @@ mv88e6xxx_smi_detect(struct device *dev, struct mii_bus *bus, int sw_addr,
>  	u16 id;
>  
>  	ops = &mv88e6xxx_smi_direct_ops;
> -	if (sw_addr > 0)
> +	if (sw_addr > 0 && info->flags & MV88E6XXX_FLAG_MULTI_CHIP)
>  		ops = &mv88e6xxx_smi_indirect_ops;

Hi Vivien

Is sw_addr is > 0 and MV88E6XXX_FLAG_MULTI_CHIP is not set, you should
return -EINVAL. The device tree is invalid.

       Andrew
