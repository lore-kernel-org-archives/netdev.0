From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 0/18] net: dsa: HW bridging, EEE support
Date: Sun, 22 Mar 2015 00:26:33 +0100
Message-ID: <20150321232633.GA15025@lunn.ch>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
 <20150321.184817.575148530596089433.davem@davemloft.net>
 <550DFADE.1080209@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	f.fainelli@gmail.com, linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <550DFADE.1080209@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >But this driver would be so much easier to read and understand if it
> >used mnemonics instead of constants for the register offsets.
> >
> 
> Yes, agreed. It is on the to-do list. Should we be more aggressive ?
> Since I'll have to resubmit anyway, we could start by adding defines
> for all constants used in this patch set, not just some of them.

It may make more sense to remove a lot of the duplicate code first.  I
have patches which centralises all the switch reset and PHY access. It
should also be possible to centralise the statistics code. At a rough
guess, that is going to remove 50% of each driver. Quite a bit of the
remainder can also be centralised, but there is where the drivers
actually start to differ, and so will take more effort.

	 Andrew
