From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] at803x: insure minimum delay for SGMII link AN
 completion ckeck
Date: Tue, 14 Feb 2017 15:50:44 +0100
Message-ID: <20170214145044.GF32480@lunn.ch>
References: <1486744943-12474-1-git-send-email-claudiu.manoil@nxp.com>
 <849590ef-2913-5c8e-56a7-a00d238d1235@neratec.com>
 <AM5PR0401MB25616E07222F4B854CB2247D96590@AM5PR0401MB2561.eurprd04.prod.outlook.com>
 <20170213173105.GE9946@lunn.ch>
 <AM5PR0401MB2561EFE479E6B2FCC508C9BD96580@AM5PR0401MB2561.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Claudiu Manoil <claudiu.manoil@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39525 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751464AbdBNOut (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Feb 2017 09:50:49 -0500
Content-Disposition: inline
In-Reply-To: <AM5PR0401MB2561EFE479E6B2FCC508C9BD96580@AM5PR0401MB2561.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 14, 2017 at 02:31:53PM +0000, Claudiu Manoil wrote:
> >-----Original Message-----
> >From: Andrew Lunn [mailto:andrew@lunn.ch]
> >Sent: Monday, February 13, 2017 7:31 PM
> >Subject: Re: [PATCH net] at803x: insure minimum delay for SGMII link AN
> >completion ckeck
> >
> 
> [...]
> 
> >>
> >> I can confirm that link status changes are signaled via interrupts ("phy_interrupt")
> >> in this case.
> >
> >Is there a way to enable an interrupt when SGMII signalled link
> >changes has happened? Maybe another interrupt enable bit somewhere?
> >That would avoid having to sleep().
> >
> 
> No, except for the interrupt lines coming from the external AR8033 PHYs there's 
> nothing else (documentation on the SoC and board is available on nxp.com).
> I think this question hints to the actual problem, that the internal SGMII link 
> should have a separate state (and state machine) apart from the external link's
> state.

Yes. I think this is something Russell Kings phylink patchset tried to
address. He has something similar. SGMII link to an SFP cage, which
could have a copper module plugged in. So again, multiple PHYs in a
chain.

	Andrew

	
