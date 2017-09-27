From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 6/6] net: dsa: mv88e6xxx: Flood broadcast frames
 in hardware
Date: Wed, 27 Sep 2017 22:18:10 +0200
Message-ID: <20170927201810.GH12394@lunn.ch>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
 <1506464764-12699-7-git-send-email-andrew@lunn.ch>
 <8737786lua.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <9733da02-0b69-33f0-de8a-63bc5cae6bb4@gmail.com>
 <20170927184636.GD12394@lunn.ch>
 <8760c4t0df.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <465be6d8-67d0-d176-1252-abb222bf0528@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:58563 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751938AbdI0USO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 27 Sep 2017 16:18:14 -0400
Content-Disposition: inline
In-Reply-To: <465be6d8-67d0-d176-1252-abb222bf0528@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 27, 2017 at 12:33:29PM -0700, Florian Fainelli wrote:
> On 09/27/2017 12:19 PM, Vivien Didelot wrote:
> > Hi Andrew, Florian,
> > 
> > Andrew Lunn <andrew@lunn.ch> writes:
> > 
> >> It took me a while to make this work with CONFIG_BRIDGE_VLAN_FILTERING
> >> enabled. Any change to enable hardware flooding needs careful testing
> >> for lots of different configurations. This is another reason i don't
> >> want to do it at the DSA level, until we have a good understanding
> >> what it means in each individual driver.
> > 
> > Then if we are worried about how broadcast flooding is handled on
> > different switches, we can provide a new .flood_broadcast(ds, vid)
> > switch operation for the drivers to implement.
> 
> We don't really have a good visibility on the number of switches
> requiring special configuration for broadcast addresses nor how this
> would have to happen so it would be a tad difficult to define an
> appropriate API with a single user.

Yes, i agree with this. We should wait before adding a generic
solution. I want to wait until a few drivers do whatever is needed for
hardware broadcast. We can then see what is common, and what is
different, find an API to suit and do some refactoring.

	   Andrew
