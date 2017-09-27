From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 6/6] net: dsa: mv88e6xxx: Flood broadcast frames
 in hardware
Date: Wed, 27 Sep 2017 20:46:36 +0200
Message-ID: <20170927184636.GD12394@lunn.ch>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
 <1506464764-12699-7-git-send-email-andrew@lunn.ch>
 <8737786lua.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <9733da02-0b69-33f0-de8a-63bc5cae6bb4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:58454 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751073AbdI0Sqk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 27 Sep 2017 14:46:40 -0400
Content-Disposition: inline
In-Reply-To: <9733da02-0b69-33f0-de8a-63bc5cae6bb4@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> What if I don't have CONFIG_BRIDGE_VLAN_FILTERING enabled, what happens
> in that case, would not this result in not programming the broadcast
> address?

Hi Florian

It took me a while to make this work with CONFIG_BRIDGE_VLAN_FILTERING
enabled. Any change to enable hardware flooding needs careful testing
for lots of different configurations. This is another reason i don't
want to do it at the DSA level, until we have a good understanding
what it means in each individual driver.

     Andrew
