From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] dsa: slave: support phy devices on external MII
 bus
Date: Mon, 16 Oct 2017 14:32:33 +0200
Message-ID: <20171016123233.GD4255@lunn.ch>
References: <20171016104525.26810-1-mnhu@prevas.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Martin =?iso-8859-1?Q?Hundeb=F8ll?= <mnhu@prevas.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:46308 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752107AbdJPMch (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 08:32:37 -0400
Content-Disposition: inline
In-Reply-To: <20171016104525.26810-1-mnhu@prevas.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 12:45:25PM +0200, Martin Hundebøll wrote:
> When configuring a switch port to use an external phy, the phy is
> connected to external switch MII bus:

Hi Martin

So this is a 6390?

So this used to work. I have a 10G phy connected to the external MII
bus on a 6390. I wonder when this got broken? Supporting phy-handle is
old code, so when i added the external MII i don't think i needed to
change any generic code.

I will take a closer look.

Thanks
  Andrew
