From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 8/9] net: dsa: bcm_sf2: Make it a real platform
 device driver
Date: Sat, 4 Jun 2016 22:55:32 +0200
Message-ID: <20160604205532.GJ2063@lunn.ch>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
 <1464998733-10405-13-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59662 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750923AbcFDUzf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jun 2016 16:55:35 -0400
Content-Disposition: inline
In-Reply-To: <1464998733-10405-13-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -static struct dsa_switch_driver bcm_sf2_switch_driver = {
> +static struct dsa_switch_driver bcm_sf2_switch_ops = {
>  	.tag_protocol		= DSA_TAG_PROTO_BRCM,
>  	.probe			= bcm_sf2_sw_drv_probe,
>  	.setup			= bcm_sf2_sw_setup,

Does this also allow you to kill bcm_sf2_sw_drv_probe?

dsa2 will never call it, and now you have your old binding parsed by
the legacy code in dsa2, you might not need it at all.

     Andrew
