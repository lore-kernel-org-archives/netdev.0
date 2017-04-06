From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 4/4] net: dsa: LAN9303: add MDIO managed mode support
Date: Thu, 6 Apr 2017 16:25:55 +0200
Message-ID: <20170406142555.GD17713@lunn.ch>
References: <20170405092024.16048-1-jbe@pengutronix.de>
 <20170405092024.16048-5-jbe@pengutronix.de>
 <20170405193219.GC25803@lunn.ch>
 <33d61a69-462f-dfb4-98f1-911882b0d466@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Juergen Borleis <jbe@pengutronix.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47831 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933624AbdDFO0E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 10:26:04 -0400
Content-Disposition: inline
In-Reply-To: <33d61a69-462f-dfb4-98f1-911882b0d466@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 06, 2017 at 06:53:10AM -0700, Florian Fainelli wrote:
> 
> 
> On 04/05/2017 12:32 PM, Andrew Lunn wrote:
> >> +static const struct of_device_id lan9303_mdio_of_match[] = {
> >> +	{ .compatible = "smsc,lan9303" },
> >> +	{ /* sentinel */ },
> >> +};
> >> +MODULE_DEVICE_TABLE(of, lan9303_mdio_of_match);
> > 
> > If i'm reading this right, i think you have the same compatible string
> > for both the i2c and the mdio driver. Does that work? I've no idea.
> 
> This should not be a problem, actually, this does seem like the right
> thing to do. The bus topology would solve the Linux device creation such
> that you would probe either via mdio or i2c (or both) but through the
> appropriate drivers' probe functions.

Hi Florian

I was more thinking about what happens when there is a call out to
userspace to find a kernel module to load to driver this hardware.  Is
the compatible string used for this? Is the subsystem string also used
when finding the correct kernel module?

	 Andrew
