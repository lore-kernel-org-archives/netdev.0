From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 1/4] net: dsa: add support for the SMSC-LAN9303
 tagging format
Date: Mon, 10 Apr 2017 15:15:33 +0200
Message-ID: <20170410131533.GA19820@lunn.ch>
References: <20170407081502.30172-1-jbe@pengutronix.de>
 <20170407081502.30172-2-jbe@pengutronix.de>
 <20170407130610.GD17290@lunn.ch>
 <201704100918.03272.jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel@pengutronix.de, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net
To: Juergen Borleis <jbe@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201704100918.03272.jbe@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Hmm. In the transmit path the driver adds four bytes of explicit data after 
> the two MACs to define the outgoing port. And the hardware uses the first 
> TAG after the two MACs to forward the packet to a specific port. How should 
> a userspace app manipulate this behaviour?

Juergen

Yes, you are right. I got thinking about the Marvell driver, can it be
made to do bad things by user space, and released my own error.

There is nothing to worry about here, sorry for the noise.

     Andrew
