From: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
Subject: Re: [git patches] net driver updates for .27
Date: Wed, 25 Jun 2008 13:13:30 +0900
Message-ID: <4861C5EA.1050900@renesas.com>
References: <20080625031508.GA29896@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Linux-sh <linux-sh@vger.kernel.org>,
	Paul Mundt <lethal@linux-sh.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-sh-owner@vger.kernel.org>
In-reply-to: <20080625031508.GA29896@havoc.gtf.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Jeff.

Jeff Garzik wrote:
> Please pull from 'davem-next' branch of
> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-next
> 
> to receive the following updates:
> 
>  Documentation/networking/dm9000.txt             |  167 ++++
>  arch/blackfin/mach-bf527/boards/ezkit.c         |    7 +-
>  arch/blackfin/mach-bf533/boards/H8606.c         |    7 +-
>  arch/blackfin/mach-bf537/boards/generic_board.c |    7 +-
>  drivers/net/Kconfig                             |   28 +-
>  drivers/net/cxgb3/cxgb3_offload.c               |   21 +-
>  drivers/net/cxgb3/t3cdev.h                      |    3 +-
>  drivers/net/dm9000.c                            | 1159 ++++++++++++-----------
>  drivers/net/dm9000.h                            |   11 +
>  drivers/net/ixgbe/ixgbe.h                       |    9 +
>  drivers/net/ixgbe/ixgbe_ethtool.c               |   11 +
>  drivers/net/ixgbe/ixgbe_main.c                  |  111 ++-
>  drivers/net/tulip/21142.c                       |    6 +-
>  drivers/net/tulip/eeprom.c                      |    6 +-
>  drivers/net/tulip/interrupt.c                   |    5 +-
>  drivers/net/tulip/media.c                       |    5 +-
>  drivers/net/tulip/pnic.c                        |    5 +-
>  drivers/net/tulip/pnic2.c                       |    5 +-
>  drivers/net/tulip/timer.c                       |    6 +-
>  drivers/net/tulip/tulip.h                       |    4 +-
>  drivers/net/tulip/tulip_core.c                  |    8 +-
>  include/linux/dm9000.h                          |    1 +
>  22 files changed, 968 insertions(+), 624 deletions(-)
>  create mode 100644 Documentation/networking/dm9000.txt
> 
> Ben Dooks (10):
>       DM9000: Add support for DM9000A and DM9000B chips
>       DM9000: Cleanups after the resource changes
>       DM9000: Cleanup source code
>       DM9000: Cleanup source code - remove forward declerations
>       DM9000: Use NSR to determine link-status on internal PHY
>       DM9000: Allow the use of the NSR register to get link status.
>       DM9000: Add missing msleep() in EEPROM wait code.
>       DM9000: Re-unite menuconfig entries for DM9000 driver
>       DM9000: Remove DEFAULT_TRIGGER for request_irq() flags.
>       DM9000: Add documentation for the driver.
> 
> Divy Le Ray (1):
>       cxgb3 - add missing adapter type for RDMA
> 
> Grant Grundler (1):
>       drivers/net/tulip: update first comment in tulip files
> 
> Laurent Pinchart (2):
>       DM9000: Remove the 2 resources probe scheme.
>       DM9000: Fixup blackfin after removing 2 resource usage
> 
> Mallikarjuna R Chilakala (1):
>       ixgbe: add LRO support

Could you take in these paches for .27 ?
[PATCH] net: sh_eth: Fix compile error sh_eth
   http://marc.info/?l=linux-netdev&m=121378156319203
[PATCH] net: sh_eth: Add support of SH7763 to sh_eth
   http://marc.info/?l=linux-netdev&m=121387121430572

Best regards,
  Nobuhiro

