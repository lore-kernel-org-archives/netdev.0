From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 0/3] Control ethernet PHY LEDs via LED subsystem
Date: Wed, 23 Mar 2016 22:10:10 +0100
Message-ID: <20160323211010.GF19953@lunn.ch>
References: <1458755500-15571-1-git-send-email-vishalthanki@gmail.com>
 <20160323185006.GL5250@lunn.ch>
 <CAC3a_SCD6aMF=triCQDJrW9GQ3HOMMH9q_J9GEw56qrnwgFXKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>, netdev@vger.kernel.org
To: Vishal Thanki <vishalthanki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55713 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751086AbcCWVKM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2016 17:10:12 -0400
Content-Disposition: inline
In-Reply-To: <CAC3a_SCD6aMF=triCQDJrW9GQ3HOMMH9q_J9GEw56qrnwgFXKA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 09:24:00PM +0100, Vishal Thanki wrote:
> Hi,
> 
> > My suggestion was that the hardware needs to control the LEDs. You
> > have software doing it. You might be able to do this with the PHY
> > state machine for link. But activity is never going to be accepted if
> > software control.
> >
> > The LED trigger attached to an LED should be used to configure the
> > hardware to drive the LED as wanted.
> >
> 
> The eth-phy-activity trigger uses the blink_set which I think uses the
> hardware acceleration if available. I am not sure how to handles LEDs
> which does not have hardware acceleration for this (eth-phy-activity)
> trigger.

We want the LED to blink on activity, real packets coming in and
out. The PHY can do this, so let the PHY control the LED. In this
case, the trigger is just mechanism for the user to say what the LED
should be used for. The trigger is not itself controlling the LED, it
has no idea about packets coming and going.

     Andrew
