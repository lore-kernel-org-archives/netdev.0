From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] r8169 / PCI / PM: Add simplified runtime PM
 support (rev. 3)
Date: Tue, 16 Mar 2010 21:29:51 -0700 (PDT)
Message-ID: <20100316.212951.91330278.davem@davemloft.net>
References: <201003150131.59619.rjw@sisk.pl>
	<201003150133.51239.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbarnes@virtuousgeek.org,
	linux-pci@vger.kernel.org, linux-pm@lists.linux-foundation.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	e1000-devel@lists.sourceforge.net, romieu@fr.zoreil.com,
	mjg59@srcf.ucam.org
To: rjw@sisk.pl
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <201003150133.51239.rjw@sisk.pl>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Mon, 15 Mar 2010 01:33:51 +0100

> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> Use the PCI runtime power management framework to add basic PCI
> runtime PM support to the r8169 driver.  Namely, make the driver
> suspend the device when the link is not present and set it up for
> generating a wakeup event after the link has been detected again.
> [This feature is disabled until the user space enables it with the
> help of the /sys/devices/.../power/contol device attribute.]
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>

Applied.
