From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] at803x: insure minimum delay for SGMII link AN
 completion ckeck
Date: Mon, 13 Feb 2017 18:31:05 +0100
Message-ID: <20170213173105.GE9946@lunn.ch>
References: <1486744943-12474-1-git-send-email-claudiu.manoil@nxp.com>
 <849590ef-2913-5c8e-56a7-a00d238d1235@neratec.com>
 <AM5PR0401MB25616E07222F4B854CB2247D96590@AM5PR0401MB2561.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Claudiu Manoil <claudiu.manoil@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37597 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752803AbdBMRbL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Feb 2017 12:31:11 -0500
Content-Disposition: inline
In-Reply-To: <AM5PR0401MB25616E07222F4B854CB2247D96590@AM5PR0401MB2561.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Yes, the phy is operating in interrupt mode.
> The phy nodes from the board's device tree have their interrupt properties set:
> http://lxr.free-electrons.com/source/arch/powerpc/boot/dts/fsl/p1010rdb-pb.dts
> 
> I can confirm that link status changes are signaled via interrupts ("phy_interrupt") 
> in this case.

Is there a way to enable an interrupt when SGMII signalled link
changes has happened? Maybe another interrupt enable bit somewhere?
That would avoid having to sleep().

     Andrew
