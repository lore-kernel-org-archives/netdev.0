From: Vishal Thanki <vishalthanki@gmail.com>
Subject: Re: [PATCH 0/3] Control ethernet PHY LEDs via LED subsystem
Date: Wed, 23 Mar 2016 21:24:00 +0100
Message-ID: <CAC3a_SCD6aMF=triCQDJrW9GQ3HOMMH9q_J9GEw56qrnwgFXKA@mail.gmail.com>
References: <1458755500-15571-1-git-send-email-vishalthanki@gmail.com> <20160323185006.GL5250@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:36345 "EHLO
	mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843AbcCWUYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 16:24:21 -0400
Received: by mail-lf0-f54.google.com with SMTP id d82so19951139lfe.3
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 13:24:20 -0700 (PDT)
In-Reply-To: <20160323185006.GL5250@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> My suggestion was that the hardware needs to control the LEDs. You
> have software doing it. You might be able to do this with the PHY
> state machine for link. But activity is never going to be accepted if
> software control.
>
> The LED trigger attached to an LED should be used to configure the
> hardware to drive the LED as wanted.
>

The eth-phy-activity trigger uses the blink_set which I think uses the
hardware acceleration if available. I am not sure how to handles LEDs
which does not have hardware acceleration for this (eth-phy-activity)
trigger.

> The exception to this is when there is no trigger attached, and the
> brightness can set the on/off state, if the hardware supports this.
>
>            Andrew
