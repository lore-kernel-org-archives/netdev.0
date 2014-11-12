From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e100: Don't enable WoL by default on Toshiba devices
Date: Wed, 12 Nov 2014 18:18:13 -0500 (EST)
Message-ID: <20141112.181813.1072534293888457853.davem@davemloft.net>
References: <1415832445-9524-1-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: linux@rainbow-software.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415832445-9524-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ondrej Zary <linux@rainbow-software.org>
Date: Wed, 12 Nov 2014 23:47:25 +0100

> Enabling WoL on some Toshiba laptops (such as Portege R100) causes battery
> drain after shutdown (WoL is active even on battery). These laptops have the
> WoL bit set in EEPROM ID, causing e100 driver to enable WoL by default.
> 
> Check subsystem vendor ID and if it's Toshiba, don't enable WoL by default
> from EEPROM settings.
> 
> Fixes https://bugs.launchpad.net/ubuntu/+source/linux/+bug/110784
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

Jeff, are you gonna pick this up?
