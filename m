From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: Re: [PATCH RFC v2 net-next 0/8] net: qualcomm: add QCA7000 UART
 driver
Date: Thu, 13 Oct 2016 10:09:09 +0200 (CEST)
Message-ID: <1257730210.379562.ef1d8693-0ff3-4b50-a424-49eebba23da1.open-xchange@email.1und1.de>
References: <1474888086-514-1-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Slaby <jslaby@suse.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474888086-514-1-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Stefan Wahren <stefan.wahren@i2se.com> hat am 26. September 2016 um 13:07
> geschrieben:
> 
> 
> The Qualcomm QCA7000 HomePlug GreenPHY supports two interfaces:
> UART and SPI. This patch series adds the missing support for UART.
> 
> This driver based on the Qualcomm code [1], but contains some changes:
> * use random MAC address per default
> * use net_device_stats from device
> * share frame decoding between SPI and UART driver
> * improve error handling
> * reimplement tty_wakeup with work queue (based on slcan)
> 
> The patches 1 - 3 are just for clean up and are not related to
> the UART support. Patches 4 - 7 prepare the existing QCA7000
> code for UART support. The last patch contains the new driver.
> 
> In order to test the driver a modified slattach in userspace is also
> required. A prepared busybox (includes slattach) can be found here [2].
> 
> The code itself has been tested on a Freescale i.MX28 board.
> 
> Changes in v2:
>   * fix build issue by using netif_trans_update() and dev_trans_start()
> 
> [1] - https://github.com/IoE/qca7000
> [2] - https://github.com/lategoodbye/busybox/commits/qca7k_support_1_24
> 

Gently ping, since i didn't receive any comment for this version.
