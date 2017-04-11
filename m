From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 1/4] net: dsa: add support for the SMSC-LAN9303
 tagging format
Date: Tue, 11 Apr 2017 16:32:21 +0200
Message-ID: <20170411143221.GG27307@lunn.ch>
References: <20170411072259.15356-1-jbe@pengutronix.de>
 <20170411072259.15356-2-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: Juergen Borleis <jbe@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170411072259.15356-2-jbe@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 11, 2017 at 09:22:56AM +0200, Juergen Borleis wrote:
> To define the outgoing port and to discover the incoming port a regular
> VLAN tag is used by the LAN9303. But its VID meaning is 'special'.
> 
> This tag handler/filter depends on some hardware features which must be
> enabled in the device to provide and make use of this special VLAN tag
> to control the destination and the source of an ethernet packet.
> 
> Signed-off-by: Juergen Borleis <jbe@pengutronix.de>

Hi Juergen

You need to rebase onto net-next, and look at the three patches
Florian added recently.

	Andrew
