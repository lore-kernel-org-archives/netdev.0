From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.33 4/4] net: Add PCI vendor and device ids for
 Micrel KSZ8841/2 PCI devices
Date: Thu, 04 Feb 2010 15:40:31 -0800 (PST)
Message-ID: <20100204.154031.124668996.davem@davemloft.net>
References: <14385191E87B904DBD836449AA30269D021A55@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tristram.Ha@Micrel.Com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <14385191E87B904DBD836449AA30269D021A55@MORGANITE.micrel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Date: Thu, 4 Feb 2010 15:28:29 -0800

> From: Tristram Ha <Tristram.Ha@micrel.com>
> 
> Add PCI vendor and device ids for Micrel KSZ8841/2 PCI devices.
> 
> Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>

We no longer add device ID defines to the linux/pci_ids.h
file, in fact it's been this way for several years.

Just use constants or local devices in your driver.

Furthermore, because you made this the last patch, the
tree would fail to build at the point where the first
three of your patches are applied.

This breaks GIT bisection, and is severely frowned upon.  The tree
must build with all available kernel config options enabled at every
step of applying your set of patches.
