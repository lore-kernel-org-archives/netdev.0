From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/3] net: dsa: Receive path simplifications
Date: Fri, 7 Apr 2017 22:53:03 +0200
Message-ID: <20170407205303.GB7966@lunn.ch>
References: <20170407204154.9651-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50298 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752094AbdDGUxH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 16:53:07 -0400
Content-Disposition: inline
In-Reply-To: <20170407204154.9651-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 07, 2017 at 01:41:51PM -0700, Florian Fainelli wrote:
> Hi all,
> 
> This patch series does factor the common code found in all tag implementations
> into dsa_switch_rcv(). The original motivation was to add GRO support, but this
> may be a lot of work with unclear benefits at this point.
> 
> Florian Fainelli (3):
>   net: dsa: Do not check for NULL dst in tag parsers
>   net: dsa: Move skb_unshare() to dsa_switch_rcv()
>   net: dsa: Factor bottom tag receive functions

Hey, are you looking in my git repo and stealing my patches? I have a
pretty much identical set :-)

I was holding off for the microchip and mediatek drivers to land, so
to not cause conflicts.

       Andrew
