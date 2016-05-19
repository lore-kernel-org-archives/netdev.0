From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/1 RFC] net/phy: Add Lantiq PHY driver
Date: Thu, 19 May 2016 14:15:43 +0200
Message-ID: <20160519121543.GB16009@lunn.ch>
References: <1463587403-26809-1-git-send-email-alexander.stein@systec-electronic.com>
 <573C9738.4040402@gmail.com>
 <20160518170109.GE25448@lunn.ch>
 <10239730.unHAU2I5Xo@ws-stein>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, john@phrozen.org
To: Alexander Stein <alexander.stein@systec-electronic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <10239730.unHAU2I5Xo@ws-stein>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> To be honest I don't know how the PHY LEDs could be set by LED triggers. 
> Wouldn't that require to create triggers for each value which can be written 
> to LEDxH and LEDxL? In my case the hardware requires some specific setting due 
> to LED connections.

Supporting all possibilities is not possible. However you could
picking out a subset which other PHYs could also implement. Think
about the typical patterns you see if you have two LEDs, which seems
to be the most common setup.

We would have generic PHY trigger code, and a driver specific part
which configures the PHY to that configuration, if the trigger is
activated.

	Andrew
