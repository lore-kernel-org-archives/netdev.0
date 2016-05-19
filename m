From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: Re: [PATCH 1/1 RFC] net/phy: Add Lantiq PHY driver
Date: Thu, 19 May 2016 09:05:07 +0200
Message-ID: <10239730.unHAU2I5Xo@ws-stein>
References: <1463587403-26809-1-git-send-email-alexander.stein@systec-electronic.com> <573C9738.4040402@gmail.com> <20160518170109.GE25448@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, john@phrozen.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160518170109.GE25448@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 18 May 2016 19:01:09, Andrew Lunn wrote:
> > For LEDs, we had a patch series floating around adding LED triggers [1],
> > and it seems to me like the LEDs class subsystem would be a good fit for
> > controlling PHY LEDs, possibly with the help of PHYLIB when it comes to
> > doing the low-level work of registering LEDs and their names with the
> > LEDS subsystem.
> > 
> > [1]: http://lists.openwall.net/netdev/2016/03/23/61
> 
> That patch fizzled out. I got the feeling it was pushing the
> capabilities of the coder. I do however think it is a reasonable path
> to follow for PHY LEDs.
> 
> I took a quick look at the datasheet and the controlling of the LEDs
> is very flexible. It should not be a problem to expose some of that
> functionality via LED triggers.

To be honest I don't know how the PHY LEDs could be set by LED triggers. 
Wouldn't that require to create triggers for each value which can be written 
to LEDxH and LEDxL? In my case the hardware requires some specific setting due 
to LED connections.
Of course making the LED configuration changeable at runtime would be awesome.

Best regards,
Alexander
