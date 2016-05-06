From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 20/20] net: dsa: mv88e6xxx: factorize the
 switch driver
Date: Fri, 6 May 2016 03:14:21 +0200
Message-ID: <20160506011421.GN7972@lunn.ch>
References: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1462488064-1841-21-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58043 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755500AbcEFBOX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2016 21:14:23 -0400
Content-Disposition: inline
In-Reply-To: <1462488064-1841-21-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +config NET_DSA_MV88E6XXX
>  	tristate "Marvell 88E6085/6095/6095F/6131 ethernet switch chip support"
>  	depends on NET_DSA
> -	select NET_DSA_MV88E6XXX
>  	select NET_DSA_TAG_EDSA
>  	---help---
>  	  This enables support for the Marvell 88E6085/6095/6095F/6131
>  	  ethernet switch chips.

Hi Vivien

You should update the list of devices. We need some text in the
tristate and help which suggests this driver supports everything
except mv88e6060.

       Andrew
