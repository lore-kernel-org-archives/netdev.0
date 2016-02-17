From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next 2/2] phy: marvell: Add support for phy packet
 generator
Date: Wed, 17 Feb 2016 23:33:07 +0100
Message-ID: <56C4F523.802@gmx.de>
References: <1455741127-25453-1-git-send-email-andrew@lunn.ch>
 <1455741127-25453-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:60024 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423442AbcBQWdW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 17:33:22 -0500
In-Reply-To: <1455741127-25453-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 17.02.2016 21:32, Andrew Lunn wrote:
> +
> +	oldpage = phy_read(phydev, MII_MARVELL_PHY_PAGE);
> +	if (oldpage < 0) {
> +		err = oldpage;
> +		goto out;
> +	}
> +

shouldn't this return immediately? Jump to out label and writing an
error value to the phy does not seem to be correct.

Regards,
Lino
