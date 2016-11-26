From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Gigabit ethernet driver for Alacritechs SLIC devices (v3)
Date: Sat, 26 Nov 2016 13:20:48 +0100
Message-ID: <1480162850-8014-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
To: davem@davemloft.net, charrer@alacritech.com, liodot@gmail.com,
 gregkh@linuxfoundation.org, andrew@lunn.ch
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
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

Hi,

this is the third version of the slicoss gigabit ethernet driver (which is a
rework of the driver from Alacritech which can currently be found under
drivers/staging/slicoss). The driver is supposed to support Mojave, Oasis and
Kalahari cards, for both copper and fiber.

If this code is accepted the staging version can be removed.

The driver has been tested on a SEN2104ET adapter (4 Port PCIe copper).

v3:
- dont add defines to pci.h but instead put it into the drivers header file
(requested by Greg Kroah-Hartman)

v2:
- remove unusual padding in statistic strings (suggested by Andrew Lunn)
- for mdio register and bit names use defines from mii.h instead of own ones
  (suggested by Andrew Lunn)
- remove unused defines
- ensure PCI flush at two more places
- use mmiowb before lock to prevent mmio writes leaking out of lock
- fix some typos in comments
- add copyright and GPL header

Regards,
Lino 
