From: Vishal Thanki <vishalthanki@gmail.com>
Subject: Re: [PATCH] net: phy: at803x: Add support to control PHY LEDs
Date: Thu, 17 Mar 2016 19:07:12 +0100
Message-ID: <20160317180710.GA22685@c50.bag.software>
References: <1458223147-16142-1-git-send-email-vishalthanki@gmail.com>
 <1458223147-16142-2-git-send-email-vishalthanki@gmail.com>
 <20160317145032.GB26019@lunn.ch>
 <56EAE277.4050109@gmail.com>
 <CAC3a_SD=chB8pPpdRm8scztJ4592J26_PmhbUkLmbE3=DCmX-w@mail.gmail.com>
 <20160317175152.GG26019@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:34231 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936184AbcCQSHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 14:07:16 -0400
Received: by mail-wm0-f46.google.com with SMTP id p65so37630376wmp.1
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 11:07:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160317175152.GG26019@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> They might not be on/off controllable individually, but you can often
> set them to show Packet RX, Packet TX, Link, speed, etc, in a
> reasonably flexible way. So you could have LED triggers mapping to
> these functionalities. The user can then pick the trigger for the LED.
> 
> Actually, the data sheet says:
> 
> 2.3.4 LED Interface
> 
> The LED interface can either be controlled by the PHY or controlled
> manually, independent of the state of the PHY. Two status LEDs are
> available. These can be used to indicate operation speed, and link
> status. The LEDs can be programmed to different status functions from
> their default value. They can also be controlled directly from the MII
> register interface.
> 
> So maybe you can control the on/off state.
> 

I need to explore more on LED subsystem. Thank you for your suggestions
and input.

Thanks,
Vishal

>    Andrew
