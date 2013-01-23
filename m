From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] drivers/net/ethernet/micrel/ks8851_mll:
 Implement basic statistics
Date: Tue, 22 Jan 2013 19:57:34 -0800
Message-ID: <1358913454.2107.16.camel@joe-AO722>
References: <FD9AD8C5375B924CABC56D982DB3A802079D32D1@EXMB1.micrel.com>
	 <20130122.205132.2281610193783011537.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David.Choi@Micrel.Com, netdev@vger.kernel.org,
	Ping.Doong@Micrel.Com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:47786 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752448Ab3AWD5g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 22:57:36 -0500
In-Reply-To: <20130122.205132.2281610193783011537.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-22 at 20:51 -0500, David Miller wrote:
> BTW it's inappropriate to log an SKB allocation failure as an error in
> the kernel logs like this.  This can be completely normal on a heavily
> loaded system.  People can look at the device statistics to learn about
> this event, or use a more sophisticated tool like the drop monitor.

There are many of these still around, though
hardly any in modern drivers.

I get this file list in drivers/net/ of
alloc_skb failures followed by printks:

Almost all of these are pretty old and are
probably best described as "don't bother".

Maybe the realtek.

drivers/net/appletalk/cops.c
drivers/net/can/grcan.c
drivers/net/can/mcp251x.c
drivers/net/can/mscan/mscan.c
drivers/net/ethernet/adi/bfin_mac.c
drivers/net/ethernet/aeroflex/greth.c
drivers/net/ethernet/amd/7990.c
drivers/net/ethernet/amd/a2065.c
drivers/net/ethernet/amd/am79c961a.c
drivers/net/ethernet/amd/au1000_eth.c
drivers/net/ethernet/amd/declance.c
drivers/net/ethernet/amd/ni65.c
drivers/net/ethernet/amd/sunlance.c
drivers/net/ethernet/cadence/at91_ether.c
drivers/net/ethernet/cirrus/cs89x0.c
drivers/net/ethernet/cirrus/mac89x0.c
drivers/net/ethernet/ethoc.c
drivers/net/ethernet/freescale/fec.c
drivers/net/ethernet/freescale/fec_mpc52xx.c
drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
drivers/net/ethernet/fujitsu/fmvj18x_cs.c
drivers/net/ethernet/i825xx/82596.c
drivers/net/ethernet/i825xx/lib82596.c
drivers/net/ethernet/microchip/enc28j60.c
drivers/net/ethernet/natsemi/sonic.c
drivers/net/ethernet/netx-eth.c
drivers/net/ethernet/nuvoton/w90p910_ether.c
drivers/net/ethernet/realtek/8139too.c
drivers/net/ethernet/realtek/atp.c
drivers/net/ethernet/seeq/sgiseeq.c
drivers/net/ethernet/sis/sis900.c
drivers/net/ethernet/smsc/smc9194.c
drivers/net/ethernet/smsc/smc91c92_cs.c
drivers/net/ethernet/smsc/smc91x.c
drivers/net/ethernet/xilinx/xilinx_emaclite.c
drivers/net/ethernet/xircom/xirc2ps_cs.c
drivers/net/hamradio/baycom_epp.c
drivers/net/hamradio/hdlcdrv.c
drivers/net/hamradio/mkiss.c
drivers/net/hippi/rrunner.c
drivers/net/irda/pxaficp_ir.c
drivers/net/sb1000.c
drivers/net/slip/slip.c
drivers/net/usb/ipheth.c
drivers/net/wan/cosa.c
drivers/net/wan/sdla.c
drivers/net/wan/x25_asy.c
drivers/net/wan/z85230.c
drivers/net/wimax/i2400m/netdev.c
drivers/net/wireless/ray_cs.c
drivers/net/wireless/wl3501_cs.c
