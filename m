From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/8] net: fec: cleanup/fixes
Date: Thu, 11 Feb 2016 06:15:27 -0500 (EST)
Message-ID: <20160211.061527.2243215315106334340.davem@davemloft.net>
References: <1454709170-19527-1-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, B38611@freescale.com,
	fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, johannes@sipsolutions.net, arnd@arndb.de
To: troy.kisky@boundarydevices.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51100 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954AbcBKLPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 06:15:33 -0500
In-Reply-To: <1454709170-19527-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Troy Kisky <troy.kisky@boundarydevices.com>
Date: Fri,  5 Feb 2016 14:52:42 -0700

> 
> V2 is a rebase on top of johannes endian-safe patch and
> is only the 1st eight patches.
> The testing for this series was done on a nitrogen6x.
> The base commit was
> commit b45efa30a626e915192a6c548cd8642379cd47cc
>     Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> 
> Testing showed no change in performance.
> Testing used imx_v6_v7_defconfig + CONFIG_MICREL_PHY.
> The processor was running at 996Mhz.
> The following commands were used to get the transfer rates.
> 
> On an x86 ubunto system,
> iperf -s -i.5 -u
> 
> 
> On a nitrogen6x board, running via SD Card.
> I first stopped some background processes
> 
> stop cron
> stop upstart-file-bridge
> stop upstart-socket-bridge
> stop upstart-udev-bridge
> stop rsyslog
> stop dbus
> killall dhclient
> echo performance >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
> 
> taskset 0x2 iperf -c 192.168.0.201 -u -t60 -b500M -r
> 
> There is a branch available on github with this series, and the rest of
> my fec patches, for those who would like to test it.
> https://github.com:boundarydevices/linux-imx6.git branch net-next_master

Series applied, thanks.
