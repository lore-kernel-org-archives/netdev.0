From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 6/6] net: dsa: mv88e6xxx: Flood broadcast frames in hardware
Date: Wed, 27 Sep 2017 15:19:56 -0400
Message-ID: <8760c4t0df.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch> <1506464764-12699-7-git-send-email-andrew@lunn.ch> <8737786lua.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <9733da02-0b69-33f0-de8a-63bc5cae6bb4@gmail.com> <20170927184636.GD12394@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:43230 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751088AbdI0TXi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 15:23:38 -0400
In-Reply-To: <20170927184636.GD12394@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew, Florian,

Andrew Lunn <andrew@lunn.ch> writes:

> It took me a while to make this work with CONFIG_BRIDGE_VLAN_FILTERING
> enabled. Any change to enable hardware flooding needs careful testing
> for lots of different configurations. This is another reason i don't
> want to do it at the DSA level, until we have a good understanding
> what it means in each individual driver.

Then if we are worried about how broadcast flooding is handled on
different switches, we can provide a new .flood_broadcast(ds, vid)
switch operation for the drivers to implement.
