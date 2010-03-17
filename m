From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] e1000e / PCI / PM: Add basic runtime PM support
 (rev. 4)
Date: Tue, 16 Mar 2010 21:29:57 -0700 (PDT)
Message-ID: <20100316.212957.45789917.davem@davemloft.net>
References: <201003150131.59619.rjw@sisk.pl>
	<201003150135.17564.rjw@sisk.pl>
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
In-Reply-To: <201003150135.17564.rjw@sisk.pl>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Mon, 15 Mar 2010 01:35:17 +0100

> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> Use the PCI runtime power management framework to add basic PCI
> runtime PM support to the e1000e driver.  Namely, make the driver
> suspend the device when the link is off and set it up for generating
> a wakeup event after the link has been detected again.  [This
> feature is disabled until the user space enables it with the help of
> the /sys/devices/.../power/contol device attribute.]
> 
> Based on a patch from Matthew Garrett.
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>

Applied.
