From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 00/16] net: dsa: HW bridging, EEE support
Date: Sun, 29 Mar 2015 13:24:38 -0700 (PDT)
Message-ID: <20150329.132438.1769032231450155025.davem@davemloft.net>
References: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Thu, 26 Mar 2015 18:36:27 -0700

> Patch 1 to 7 of this series prepare the drivers using the mv88e6xxx code
> for HW bridging support, without adding the code itself. For the most part
> this factors out common port initialization code. There is no functional
> change except for patch 3, which disables the message port bit for the
> CPU port to prevent packet duplication if HW bridging is configured.
> 
> Patch 8 adds the infrastructure for hardware bridging support to the
> mv88e6xxx code.
> 
> Patch 9 wires the MV88E6352 driver to support hardware bridging.
> 
> Patches 10 to 12 add support for ndo_fdb functions to the dsa subsystem,
> and wire up the MV88E6352 driver to support those functions.
> 
> Patches 13 to 16 add EEE support and HW bridging support to the mv88e6171
> driver. This set of patches is from Andrew, applied on top of the first
> set of patches.
> 
> The series applies to net-next as of 3/24/2015.
> 
> Thanks a lot to Andrew Lunn for testing and valuable feedback.

Series applied, thanks!
