From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] phy state machine: failsafe leave invalid RUNNING state
Date: Wed, 4 Jan 2017 17:16:15 +0100
Message-ID: <20170104161615.GF5517@lunn.ch>
References: <1483542298-9747-1-git-send-email-zefir.kurtisi@neratec.com>
 <6845805d-4dae-0a3a-c56c-6feb86f4b553@gmail.com>
 <82ffbb43-9345-c47d-596c-73c175ac7e7f@neratec.com>
 <16a741c1-7005-b1df-f2e6-afdbe9d086c8@gmail.com>
 <8521b51f-04f7-aeef-f862-bb150257cfa4@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42995 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750958AbdADQQs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 11:16:48 -0500
Content-Disposition: inline
In-Reply-To: <8521b51f-04f7-aeef-f862-bb150257cfa4@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The setup is as follows:
> mv88e6321:
> * ports 0+1 connected to fibre-optics transceivers at fixed 100 Mbps
> * port 4 is CPU port
> * custom phy driver (replacement for marvell.ko) only populated with
>   * .config_init to
>     * set fixed speed for ports 0+1 (when in FO mode)
>     * run genphy_config_init() for all other modes (here: CPU port)
>   * .config_aneg=genphy_config_aneg, .read_status=genphy_read_status

Kicking off a side discussion:

Why do a custom PHY driver? What cannot you do with the current DSA
code? I've got boards with two FO ports, and using fixed-phy is all i
need to make them work on a 6352.

     Andrew
