From: David Miller <davem@davemloft.net>
Subject: Re: Gigabit ethernet driver for Alacritechs SLIC devices (v4)
Date: Tue, 06 Dec 2016 11:30:04 -0500 (EST)
Message-ID: <20161206.113004.1297109434722530511.davem@davemloft.net>
References: <1480975637-18245-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, andrew@lunn.ch, f.fainelli@gmail.com,
 roszenrami@gmail.com, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
 liodot@gmail.com, netdev@vger.kernel.org
To: LinoSanfilippo@gmx.de
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1480975637-18245-1-git-send-email-LinoSanfilippo@gmx.de>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Date: Mon,  5 Dec 2016 23:07:15 +0100

> this is the forth version of the slicoss gigabit ethernet driver (which is a
> rework of the driver from Alacritech which can currently be found under
> drivers/staging/slicoss). The driver is supposed to support Mojave, Oasis and
> Kalahari cards, for both copper and fiber.
> 
> If this code is accepted the staging version can be removed.
> 
> The driver has been tested on a SEN2104ET adapter (4 Port PCIe copper).

I've applied this series, nice work.

But realize that if you use SLICOSS as the Kconfig symbol to select
this driver, then while the staging driver is still in the tree it
will enable both drivers which both want to attach to the same exact
device IDs.
