From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: cpsw fails to come up once in a while
Date: Thu, 15 Aug 2013 15:29:27 +0530
Message-ID: <520CA67F.4000902@ti.com>
References: <20130814175439.GA13483@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:38562 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753605Ab3HOJ7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 05:59:38 -0400
In-Reply-To: <20130814175439.GA13483@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 14 August 2013 11:24 PM, Sebastian Andrzej Siewior wrote:
> Hi,
>
> So I have this test where my am335x-evm boots over NFS and once it=20
> completes it does it again. It works most of the time :) However once=
 it
> like 100 attempts it does not. After the reset u-boot complains about
> ethernet timeout and linux has also no luck:
>
> | U-Boot 2013.04-00274-ga71d45d (May 27 2013 - 12:41:57)
> |=20
> |=E2=80=A6
> | Net:   Phy not found
> | PHY reset timed out
> | cpsw, usb_ether
> | Hit any key to stop autoboot:  1 ^H^H^H 0=20
> | link up on port 0, speed 1000, full duplex
> | Using cpsw device
> | TFTP from server 172.123.10.10; our IP address is 172.123.10.3
> | Filename 'am335x/zImage'.
> | Load address: 0x80200000
> | Loading: *^H#######################################################=
##########
> |          ##########################################################=
#######
> |          #######################################
> |          509.8 KiB/s
>
> So the PHY was not found but somehow it managed to fetch the kernel o=
ver
> network and boot it. The linux driver did not want to continue:
>
> | omap_i2c 4802a000.i2c: bus 1 rev0.11 at 100 kHz
> | davinci_mdio 4a101000.mdio: davinci mdio revision 1.6
> | davinci_mdio 4a101000.mdio: no live phy, scanning all
> | davinci_mdio: probe of 4a101000.mdio failed with error -5
> | Random MACID =3D 16:74:44:51:f1:0f
> | gpio-keys volume_keys.6: Unable to claim irq 0; error -22
> | gpio-keys: probe of volume_keys.6 failed with error -22
> | omap_rtc 44e3e000.rtc: setting system clock to 2000-01-01 03:22:52 =
UTC (946696972)
> | net eth0: initializing cpsw version 1.12 (0)
> | libphy: PHY 4a101000.mdio:00 not found
> | net eth0: phy 4a101000.mdio:00 not found on slave 0
> | libphy: PHY 4a101000.mdio:01 not found
> | net eth0: phy 4a101000.mdio:01 not found on slave 1
> | Waiting up to 110 more seconds for network.
>
> so the driver also failed to find a PHY and gave up.
> Is this something known?
>
> Sebastian
This is a unknown issue. Will arrange a setup to test this scenario and
fix the issue.

Regards
Mugunthan V N
