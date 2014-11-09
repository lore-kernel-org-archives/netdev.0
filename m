From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: e100: Laptop battery drain and WoL settings from EEPROM
Date: Mon, 10 Nov 2014 00:34:37 +0100
Message-ID: <20141109233437.GA5037@electric-eye.fr.zoreil.com>
References: <201411090015.41446.linux@rainbow-software.org>
 <201411091918.04036.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201411091918.04036.linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ondrej Zary <linux@rainbow-software.org> :
[...]
> > Looks like this laptop is probably WoL-capable even on battery.
> >
> > Measured the current from AC adapter:
> > around 20mA with WoL inactive (shut down from Windows or by power button in
> > GRUB) around 40mA with WoL active (shut down from Linux)
> >
> > So to work-around this problem, users must disable WoL manually on each
> > boot.

Or configure udev so that ethtool disables WoL.

The current policy has been here for ages. Some users may rely on it.

There must be some strong rationale for their setup to have to be changed.

-- 
Ueimor
