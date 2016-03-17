From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: at803x: Add support to control PHY LEDs
Date: Thu, 17 Mar 2016 18:51:52 +0100
Message-ID: <20160317175152.GG26019@lunn.ch>
References: <1458223147-16142-1-git-send-email-vishalthanki@gmail.com>
 <1458223147-16142-2-git-send-email-vishalthanki@gmail.com>
 <20160317145032.GB26019@lunn.ch>
 <56EAE277.4050109@gmail.com>
 <CAC3a_SD=chB8pPpdRm8scztJ4592J26_PmhbUkLmbE3=DCmX-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>, netdev@vger.kernel.org
To: Vishal Thanki <vishalthanki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49599 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933022AbcCQRvy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2016 13:51:54 -0400
Content-Disposition: inline
In-Reply-To: <CAC3a_SD=chB8pPpdRm8scztJ4592J26_PmhbUkLmbE3=DCmX-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I agree with the idea of making a generic callback in phy_driver so
> that other PHYs
> can use it. However I think these LEDs are tightly coupled with PHYs and it
> would not make much sense to expose them via LED subsystem as they
> cannot be controlled individually IMHO.

They might not be on/off controllable individually, but you can often
set them to show Packet RX, Packet TX, Link, speed, etc, in a
reasonably flexible way. So you could have LED triggers mapping to
these functionalities. The user can then pick the trigger for the LED.

Actually, the data sheet says:

2.3.4 LED Interface

The LED interface can either be controlled by the PHY or controlled
manually, independent of the state of the PHY. Two status LEDs are
available. These can be used to indicate operation speed, and link
status. The LEDs can be programmed to different status functions from
their default value. They can also be controlled directly from the MII
register interface.

So maybe you can control the on/off state.

   Andrew
