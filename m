From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/1 RFC] net/phy: Add Lantiq PHY driver
Date: Wed, 18 May 2016 19:01:09 +0200
Message-ID: <20160518170109.GE25448@lunn.ch>
References: <1463587403-26809-1-git-send-email-alexander.stein@systec-electronic.com>
 <573C9738.4040402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Stein <alexander.stein@systec-electronic.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john@phrozen.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <573C9738.4040402@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> For LEDs, we had a patch series floating around adding LED triggers [1],
> and it seems to me like the LEDs class subsystem would be a good fit for
> controlling PHY LEDs, possibly with the help of PHYLIB when it comes to
> doing the low-level work of registering LEDs and their names with the
> LEDS subsystem.
> 
> [1]: http://lists.openwall.net/netdev/2016/03/23/61

That patch fizzled out. I got the feeling it was pushing the
capabilities of the coder. I do however think it is a reasonable path
to follow for PHY LEDs.

I took a quick look at the datasheet and the controlling of the LEDs
is very flexible. It should not be a problem to expose some of that
functionality via LED triggers.

      Andrew
