From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v8 net-next 00/17] net: qualcomm: add QCA7000 UART
 driver
Date: Tue, 30 May 2017 14:03:58 -0400 (EDT)
Message-ID: <20170530.140358.891038297917804466.davem@davemloft.net>
References: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, jslaby-IBi9RG/b67k@public.gmane.org, LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org,
        kubakici-5tc4TXWwyLM@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: stefan.wahren-eS4NqCHxEME@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1496059045-13572-1-git-send-email-stefan.wahren-eS4NqCHxEME@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
Date: Mon, 29 May 2017 13:57:08 +0200

> The Qualcomm QCA7000 HomePlug GreenPHY supports two interfaces:
> UART and SPI. This patch series adds the missing support for UART.
> 
> This driver based on the Qualcomm code [1], but contains some changes:
> * use random MAC address per default
> * use net_device_stats from device
> * share frame decoding between SPI and UART driver
> * improve error handling
> * reimplement tty_wakeup with work queue (based on slcan)
> * use new serial device bus instead of ldisc
> 
> The patches 1 - 3 are just for clean up and are not related to
> the UART support. Patch 4 adds SET_NETDEV_DEV() to qca_spi.
> Patches 5 - 16 prepare the existing QCA7000 code for UART support.
> The last patch contains the new driver.
> 
> The code itself has been tested on a Freescale i.MX28 board and
> a Raspberry Pi Zero.

Series applied, thank you.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
