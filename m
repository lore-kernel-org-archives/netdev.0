From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 6/6] net: dsa: mv88e6xxx: Flood broadcast frames
 in hardware
Date: Wed, 27 Sep 2017 20:36:50 +0200
Message-ID: <20170927183650.GC12394@lunn.ch>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
 <1506464764-12699-7-git-send-email-andrew@lunn.ch>
 <8737786lua.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:58433 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751590AbdI0Sgx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 27 Sep 2017 14:36:53 -0400
Content-Disposition: inline
In-Reply-To: <8737786lua.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Adding the broadcast address to an Ethernet switch's FDB is pretty
> generic and mv88e6xxx mustn't be the only driver doing this.

Actually, it is. All the others seem to do this in hardware without
needing an FDB. Since mv88e6xxx is the only one requiring it, it has
to be done in the mv88e6xxx driver.

   Andrew
