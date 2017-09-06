From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 rfc 0/8] IGMP snooping for local traffic
Date: Wed, 6 Sep 2017 17:16:40 +0200
Message-ID: <20170906151640.GC15315@lunn.ch>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
 <20170906004703.GB27385@lunn.ch>
 <edf02eb7-e6bf-e88c-f655-40f6f71a3446@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Woojung.Huh@microchip.com, jbe@pengutronix.de,
        sean.wang@mediatek.com, john@phrozen.org
To: Matthias May <matthias.may@neratec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58760 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932657AbdIFPQq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 11:16:46 -0400
Content-Disposition: inline
In-Reply-To: <edf02eb7-e6bf-e88c-f655-40f6f71a3446@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 06, 2017 at 04:46:51PM +0200, Matthias May wrote:
> 
> Hi Andrew
> We are using the 88E6321.
> In our setup we are using openvswitch and not a bridge, however the problem you describe seems to be the same.
> 
> We had to configure the switch to flood unknown multicast (Egress Floods = 0x3, bits 3:2, offset 0x4 in port control)
> and
> unset FloodBC (FloodBC = 0x0, bit 12, offset 0x5 in global 2) which defines if a broadcast should be considered as
> multicast for the above config.

Hi Matthias

I might look at this.

But architecturally it seems better to add an mdb entry for the
broadcast address. I hope that work across all switches, where as what
you suggests only works for Marvell devices.

    Andrew
