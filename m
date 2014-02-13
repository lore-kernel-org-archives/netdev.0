From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 00/10] Support for Broadcom GENET driver
Date: Wed, 12 Feb 2014 16:23:03 -0800
Message-ID: <CAGVrzcbrYXr4x3HJq=ztuYSMp7P63zgLohjAJe5jAGjeWb=LhA@mail.gmail.com>
References: <1392178053-3143-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Kevin Cernekee <cernekee@gmail.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:55877 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381AbaBMAXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 19:23:44 -0500
In-Reply-To: <1392178053-3143-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-11 20:07 GMT-08:00 Florian Fainelli <f.fainelli@gmail.com>:
> Hi all,
>
> This patchset adds support for the Broadcom GENET Gigabit Ethernet MAC
> controller. This controller is found on the Broadcom BCM7xxx Set Top Box
> System-on-a-Chip.

I just found a small bug in the main driver file, and due to my
previous series touching libphy, this will not apply cleanly anymore.
I will wait for some initial feedback before doing a second respin
though.

>
> Florian Fainelli (10):
>   net: phy: add "internal" PHY mode
>   net: phy: add MoCA PHY type
>   net: phy: update port type for MoCA PHYs
>   net: phy: add Broadcom BCM7xxx internal PHY driver
>   net: bcmgenet: add driver definitions and private structure
>   net: bcmgenet: add main driver file
>   net: bcmgenet: add MDIO routines
>   net: bcmgenet: hook into the build system
>   Documentation: add Device tree bindings for Broadcom GENET
>   MAINTAINERS: add entry for the Broadcom GENET driver
>
>  .../devicetree/bindings/net/broadcom-bcmgenet.txt  |  111 +
>  MAINTAINERS                                        |    6 +
>  drivers/net/ethernet/broadcom/Kconfig              |   10 +
>  drivers/net/ethernet/broadcom/Makefile             |    1 +
>  drivers/net/ethernet/broadcom/genet/Makefile       |    2 +
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c     | 2685 ++++++++++++++++++++
>  drivers/net/ethernet/broadcom/genet/bcmgenet.h     |  631 +++++
>  drivers/net/ethernet/broadcom/genet/bcmmii.c       |  483 ++++
>  drivers/net/phy/Kconfig                            |    6 +
>  drivers/net/phy/Makefile                           |    1 +
>  drivers/net/phy/bcm7xxx.c                          |  322 +++
>  drivers/net/phy/phy.c                              |    5 +-
>  drivers/of/of_net.c                                |    2 +
>  include/linux/brcmphy.h                            |    9 +
>  include/linux/phy.h                                |    5 +-
>  15 files changed, 4277 insertions(+), 2 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/broadcom-bcmgenet.txt
>  create mode 100644 drivers/net/ethernet/broadcom/genet/Makefile
>  create mode 100644 drivers/net/ethernet/broadcom/genet/bcmgenet.c
>  create mode 100644 drivers/net/ethernet/broadcom/genet/bcmgenet.h
>  create mode 100644 drivers/net/ethernet/broadcom/genet/bcmmii.c
>  create mode 100644 drivers/net/phy/bcm7xxx.c
>
> --
> 1.8.3.2
>



-- 
Florian
