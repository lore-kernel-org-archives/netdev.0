From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 net-next] net: phy: Add LED mode driver for Microsemi
 PHYs.
Date: Thu, 16 Feb 2017 15:19:17 +0100
Message-ID: <20170216141917.GA17550@lunn.ch>
References: <1486474826-29426-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20170215164540.eok7bnudfffzoyi4@rob-hp-laptop>
 <20170216090646.GA29082@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh@kernel.org>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, f.fainelli@gmail.com,
        Allan.Nielsen@microsemi.com
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41851 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754504AbdBPOTU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 09:19:20 -0500
Content-Disposition: inline
In-Reply-To: <20170216090646.GA29082@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 16, 2017 at 02:36:48PM +0530, Raju Lakkaraju wrote:
> Hi Rob,
> 
> On Wed, Feb 15, 2017 at 10:45:40AM -0600, Rob Herring wrote:
> > EXTERNAL EMAIL
> > 
> > 
> > On Tue, Feb 07, 2017 at 07:10:26PM +0530, Raju Lakkaraju wrote:
> > > From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> > >
> > > +                       Default value is VSC8531_LINK_1000_ACTIVITY (1).
> > > +- vsc8531,led-1-mode : LED mode. Specify how the LED[1] should behave.
> > 
> > You failed to address my comment on v2. vsc8531 is not a vendor prefix.
> > Please fix in a new patch since David already applied it.
> > 
> 
> Accpeted my fault. i missed your comment.
> Do i need to change from  "vsc8531, led-0-mode" to "mscc, led-0-mode"
> Is this your suggestion?

Hi Raju

Are there any in kernel users of this binding? I don't think there
are. I know Microsemi has a modified beagle bone black available as a
development board, but i don't think mainline support for this board
has been added yet?

Since there is nothing to remain backwards compatible with, you could
change all the property names?

       Andrew
