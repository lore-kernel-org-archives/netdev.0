From: Sjoerd Simons <sjoerd.simons@collabora.co.uk>
Subject: Re: [PATCH] net: phy: turn carrier off on phy attach
Date: Thu, 14 Jan 2016 21:22:57 +0100
Message-ID: <1452802977.30596.46.camel@collabora.co.uk>
References: <1452365045-5364-1-git-send-email-sjoerd.simons@collabora.co.uk>
	 <10DF45FB-A812-4D6F-8B45-817B86FD48CE@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <10DF45FB-A812-4D6F-8B45-817B86FD48CE@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-01-12 at 17:31 -0800, Florian Fainelli wrote:
> On January 9, 2016 10:44:05 AM PST, Sjoerd Simons <sjoerd.simons@coll
> abora.co.uk> wrote:
> > The operstate of a networking device initially IF_OPER_UNKNOWN aka
> > "unknown", updated on carrier state changes (with carrier state
> > being
> > on
> > by default). This means it will stay unknown unless the carrier
> > state
> > goes to off at some point, which is not the case if the phy is
> > already
> > up/connected at startup.
> 
> Correct, drivers typically call netif_carrier_off prior to
> registering the network device to give a predictable link state,
> regardless of whether or not they use PHYLIB.
> 
> > 
> > Explicitly turn off the carrier on phy attach, leaving the phy
> > state
> > machine to turn the carrier on when it has done the initial
> > negotiation.
> 
> Same comment as Andrew on the comment below.
> 
> Out of curiosity, was there a particular driver you ran into issues
> with?

Prepping a v2. This came up on Rada Rock2 board, so the (Rockchip)
DWMAC driver combined with a realtek phy (RTL8211E). Thanks for the
review

-- 
Sjoerd Simons
Collabora Ltd.
