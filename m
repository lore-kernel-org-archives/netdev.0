From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 0/5] Generic PHY Framework
Date: Tue, 19 Feb 2013 10:44:28 +0000
Message-ID: <201302191044.28653.arnd@arndb.de>
References: <1361253198-7401-1-git-send-email-kishon@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: rob@landley.net, tony@atomide.com, linux@arm.linux.org.uk,
	eballetbo@gmail.com, javier@dowhile0.org, balbi@ti.com,
	gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	mchehab@redhat.com, cesarb@cesarb.net, davem@davemloft.net,
	santosh.shilimkar@ti.com, broonie@opensource.wolfsonmicro.com,
	swarren@nvidia.com, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Kishon Vijay Abraham I <kishon@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1361253198-7401-1-git-send-email-kishon@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 19 February 2013, Kishon Vijay Abraham I wrote:
> Added a generic PHY framework that provides a set of APIs for the PHY drivers
> to create/destroy a PHY and APIs for the PHY users to obtain a reference to
> the PHY with or without using phandle. To obtain a reference to the PHY
> without using phandle, the platform specfic intialization code (say from board
> file) should have already called phy_bind with the binding information. The
> binding information consists of phy's device name, phy user device name and an
> index. The index is used when the same phy user binds to mulitple phys.
> 
> This framework will be of use only to devices that uses external PHY (PHY
> functionality is not embedded within the controller).
> 
> The intention of creating this framework is to bring the phy drivers spread
> all over the Linux kernel to drivers/phy to increase code re-use and to
> increase code maintainability.
> 
> Comments to make PHY as bus wasn't done because PHY devices can be part of
> other bus and making a same device attached to multiple bus leads to bad
> design.

How does this relate to the generic PHY interfaces in drivers/net/phy?

Do you expect that to get merged into drivers/phy in the long run, or
do you want to keep the generic phy only for everything but ethernet?

I think it would be problematic to have two alternative interfaces for
ethernet PHYs because then an ethernet driver still needs to decide
which subsystem to interface with.

	Arnd
