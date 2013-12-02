From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] PCI / tg3: Give up chip reset and carrier loss
 handling if PCI device is not present
Date: Mon, 02 Dec 2013 16:02:19 -0500 (EST)
Message-ID: <20131202.160219.837472723344445995.davem@davemloft.net>
References: <7807315.7cU9KldDtM@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-pm@vger.kernel.org, linux-pci@vger.kernel.org,
	bhelgaas@google.com, nsujir@broadcom.com, mchan@broadcom.com
To: rjw@rjwysocki.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7807315.7cU9KldDtM@vostro.rjw.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Date: Sun, 01 Dec 2013 02:34:37 +0100

> From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> 
> Modify tg3_chip_reset() and tg3_close() to check if the PCI network
> adapter device is accessible at all in order to skip poking it or
> trying to handle a carrier loss in vain when that's not the case.
> Introduce a special PCI helper function pci_device_is_present()
> for this purpose.
> 
> Of course, this uncovers the lack of the appropriate RTNL locking
> in tg3_suspend() and tg3_resume(), so add that locking in there
> too.
> 
> These changes prevent tg3 from burning a CPU at 100% load level for
> solid several seconds after the Thunderbolt link is disconnected from
> a Matrox DS1 docking station.
> 
> Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

Applied, thanks everyone.
