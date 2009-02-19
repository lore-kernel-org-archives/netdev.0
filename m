From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] niu: improve ethtool support for gigabit copper
 cards
Date: Wed, 18 Feb 2009 17:53:41 -0800 (PST)
Message-ID: <20090218.175341.142384927.davem@davemloft.net>
References: <20090217103852.48b110af.baranov@mercdev.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: baranov@mercdev.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54150
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751954AbZBSBx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 20:53:57 -0500
In-Reply-To: <20090217103852.48b110af.baranov@mercdev.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Constantin Baranov <baranov@mercdev.com>
Date: Tue, 17 Feb 2009 10:38:52 +0400

> Introduced support for link speed and duplex setting (ethtool -s),
> link advertising parameters and autonegotiation (ethtool -r):
> - struct niu_link_config: split advertising and autoneg
>   fields into active and target values (similar to speed
>   and duplex fields)
> - mii_init_common(): rewrite function to actually apply
>   requested niu_link_config parameters instead of providing
>   default initialization
> - link_status_1g(): move parsing of MII registers into
>   new link_status_mii() function (link_status_1g_rgmii()
>   could possibly use this new implementation too)
> - introduce simple nway_reset method
> - fix incorrect XMAC_CONFIG_MODE selection for 10Mbps case
> 
> Signed-off-by: Constantin Baranov <baranov@mercdev.com>

Looks good, patch applied, thanks.
